#!/usr/bin/env python3
"""Tests for the ./install script.

Run them with:

    python3 .tests/test_install.py

Stdlib only, same as the script under test. Two layers:

* unit tests, which import ./install and exercise its functions directly
  against a temporary $HOME
* end-to-end tests, which run the real script inside a pty with a stub `stow`
  on PATH, so the interactive checklist and prompts are covered too

Nothing here touches the real $HOME or the real repo.
"""

import importlib.machinery
import importlib.util
import os
import pty
import re
import select
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
INSTALL_SCRIPT = REPO_ROOT / "install"


def load_installer():
    """Import ./install as a module. It has no .py extension, so the loader
    has to be named explicitly."""
    loader = importlib.machinery.SourceFileLoader("installer", str(INSTALL_SCRIPT))
    spec = importlib.util.spec_from_loader("installer", loader)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


installer = load_installer()


# A stand-in for GNU stow, so the tests don't depend on it being installed.
# Implements just the flags the script passes: --no-folding, -d, -t and -D.
STUB_STOW = '''#!/usr/bin/env python3
import os, sys
from pathlib import Path

args, delete, d, t, pkgs = sys.argv[1:], False, None, None, []
i = 0
while i < len(args):
    a = args[i]
    if a == "-D":
        delete = True
    elif a == "-d":
        i += 1; d = args[i]
    elif a == "-t":
        i += 1; t = args[i]
    elif a != "--no-folding":
        pkgs.append(a)
    i += 1

conflicts = []
for pkg in pkgs:
    base = Path(d) / pkg
    for root, _, files in os.walk(base):
        for f in files:
            src = Path(root, f)
            dst = Path(t) / src.relative_to(base)
            if delete:
                if dst.is_symlink() and os.path.realpath(dst) == str(src.resolve()):
                    dst.unlink()
            elif dst.is_symlink() or dst.exists():
                conflicts.append(str(dst))
            else:
                dst.parent.mkdir(parents=True, exist_ok=True)
                dst.symlink_to(src)

for x in conflicts:
    print("stow: cannot stow over existing target " + x, file=sys.stderr)
sys.exit(1 if conflicts else 0)
'''


# --------------------------------------------------------------------------
# unit tests
# --------------------------------------------------------------------------

class InstallerTestCase(unittest.TestCase):
    """Builds a throwaway repo + $HOME and points the module at them."""

    packages = {
        "appa": {".config/appa/appa.conf": "appa config"},
        "appb": {".appbrc": "appb config"},
        "appc": {".config/appc/one.conf": "one", ".config/appc/two.conf": "two"},
    }

    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="dotfiles-test-"))
        self.repo = self.tmp / "repo"
        self.home = self.tmp / "home"
        self.home.mkdir(parents=True)

        for pkg, files in self.packages.items():
            for rel, content in files.items():
                path = self.repo / pkg / rel
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content)

        self._saved = (installer.REPO, installer.HOME, installer.BACKUP_ROOT)
        installer.REPO = self.repo
        installer.HOME = self.home
        installer.BACKUP_ROOT = self.home / ".dotfiles-backups"

    def tearDown(self):
        installer.REPO, installer.HOME, installer.BACKUP_ROOT = self._saved
        shutil.rmtree(self.tmp, ignore_errors=True)

    # helpers -------------------------------------------------------------

    def link(self, pkg, rel):
        """Symlink one file the way stow would."""
        target = self.home / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.symlink_to(self.repo / pkg / rel)
        return target

    def write_home(self, rel, content="pre-existing"):
        target = self.home / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content)
        return target


class TestPackageScanning(InstallerTestCase):

    def test_entries_are_relative_paths(self):
        pkg = installer.Package("appa")
        self.assertEqual(pkg.entries, [Path(".config/appa/appa.conf")])

    def test_entries_are_sorted(self):
        pkg = installer.Package("appc")
        self.assertEqual(
            pkg.entries,
            [Path(".config/appc/one.conf"), Path(".config/appc/two.conf")],
        )

    def test_ds_store_is_ignored(self):
        (self.repo / "appb" / ".DS_Store").write_text("junk")
        self.assertEqual(installer.Package("appb").entries, [Path(".appbrc")])

    def test_discover_finds_all_packages(self):
        names = [p.name for p in installer.discover_packages()]
        self.assertEqual(names, ["appa", "appb", "appc"])

    def test_discover_skips_hidden_directories(self):
        hidden = self.repo / ".install"
        hidden.mkdir()
        (hidden / "bootstrap.sh").write_text("#!/bin/sh\n")
        names = [p.name for p in installer.discover_packages()]
        self.assertNotIn(".install", names)

    def test_discover_skips_empty_directories(self):
        (self.repo / "empty").mkdir()
        names = [p.name for p in installer.discover_packages()]
        self.assertNotIn("empty", names)

    def test_discover_skips_loose_files(self):
        (self.repo / "readme.md").write_text("# hi")
        names = [p.name for p in installer.discover_packages()]
        self.assertNotIn("readme.md", names)


class TestStateDetection(InstallerTestCase):

    def test_missing_when_nothing_at_target(self):
        pkg = installer.Package("appb")
        self.assertEqual(pkg.state_of(Path(".appbrc")), installer.MISSING)
        self.assertFalse(pkg.installed)
        self.assertFalse(pkg.partial)

    def test_linked_when_symlink_points_into_repo(self):
        self.link("appb", ".appbrc")
        pkg = installer.Package("appb")
        self.assertEqual(pkg.state_of(Path(".appbrc")), installer.LINKED)
        self.assertTrue(pkg.installed)

    def test_conflict_when_real_file_present(self):
        self.write_home(".appbrc")
        pkg = installer.Package("appb")
        self.assertEqual(pkg.state_of(Path(".appbrc")), installer.CONFLICT)
        self.assertEqual(pkg.conflicts(), [Path(".appbrc")])

    def test_conflict_when_symlink_points_elsewhere(self):
        other = self.tmp / "somewhere-else"
        other.write_text("not ours")
        (self.home / ".appbrc").symlink_to(other)
        pkg = installer.Package("appb")
        self.assertEqual(pkg.state_of(Path(".appbrc")), installer.CONFLICT)

    def test_broken_symlink_counts_as_conflict(self):
        (self.home / ".appbrc").symlink_to(self.tmp / "does-not-exist")
        pkg = installer.Package("appb")
        self.assertEqual(pkg.state_of(Path(".appbrc")), installer.CONFLICT)

    def test_partial_when_only_some_files_linked(self):
        self.link("appc", ".config/appc/one.conf")
        pkg = installer.Package("appc")
        self.assertTrue(pkg.partial)
        self.assertFalse(pkg.installed)
        self.assertEqual(pkg.linked_count, 1)
        self.assertIn("1/2 linked", pkg.status_label())

    def test_fully_linked_is_installed_not_partial(self):
        self.link("appc", ".config/appc/one.conf")
        self.link("appc", ".config/appc/two.conf")
        pkg = installer.Package("appc")
        self.assertTrue(pkg.installed)
        self.assertFalse(pkg.partial)


class TestBackupAndRestore(InstallerTestCase):

    def test_backup_moves_file_and_preserves_layout(self):
        original = self.write_home(".config/appa/appa.conf", "original")
        pkg = installer.Package("appa")
        snapshot = installer.backup_paths(pkg, pkg.conflicts(), "2020-01-01_00-00-00")

        self.assertFalse(original.exists())
        saved = snapshot / ".config/appa/appa.conf"
        self.assertEqual(saved.read_text(), "original")

    def test_backup_dry_run_leaves_file_alone(self):
        original = self.write_home(".appbrc", "original")
        pkg = installer.Package("appb")
        installer.backup_paths(pkg, pkg.conflicts(), "stamp", dry_run=True)

        self.assertTrue(original.exists())
        self.assertEqual(original.read_text(), "original")

    def test_remove_paths_deletes_file(self):
        target = self.write_home(".appbrc")
        pkg = installer.Package("appb")
        installer.remove_paths(pkg, pkg.conflicts())
        self.assertFalse(target.exists())

    def test_remove_paths_dry_run_keeps_file(self):
        target = self.write_home(".appbrc")
        pkg = installer.Package("appb")
        installer.remove_paths(pkg, pkg.conflicts(), dry_run=True)
        self.assertTrue(target.exists())

    def test_backups_listed_newest_first(self):
        root = installer.BACKUP_ROOT / "appb"
        for stamp in ("2020-01-01_00-00-00", "2024-06-01_12-00-00"):
            (root / stamp).mkdir(parents=True)
        self.assertEqual(
            [d.name for d in installer.Package("appb").backups()],
            ["2024-06-01_12-00-00", "2020-01-01_00-00-00"],
        )

    def test_no_backups_when_directory_absent(self):
        self.assertEqual(installer.Package("appb").backups(), [])

    def test_restore_puts_file_back(self):
        pkg = installer.Package("appb")
        snapshot = installer.BACKUP_ROOT / "appb" / "2020-01-01_00-00-00"
        (snapshot).mkdir(parents=True)
        (snapshot / ".appbrc").write_text("original")

        restored, skipped = installer.restore_backup(pkg, snapshot)

        self.assertEqual((restored, skipped), (1, 0))
        self.assertEqual((self.home / ".appbrc").read_text(), "original")

    def test_restore_skips_occupied_targets(self):
        self.write_home(".appbrc", "something new")
        pkg = installer.Package("appb")
        snapshot = installer.BACKUP_ROOT / "appb" / "2020-01-01_00-00-00"
        snapshot.mkdir(parents=True)
        (snapshot / ".appbrc").write_text("original")

        restored, skipped = installer.restore_backup(pkg, snapshot)

        self.assertEqual((restored, skipped), (0, 1))
        self.assertEqual((self.home / ".appbrc").read_text(), "something new")
        self.assertTrue((snapshot / ".appbrc").exists(), "backup must be kept")

    def test_emptied_snapshot_is_cleaned_up(self):
        pkg = installer.Package("appb")
        snapshot = installer.BACKUP_ROOT / "appb" / "2020-01-01_00-00-00"
        snapshot.mkdir(parents=True)
        (snapshot / ".appbrc").write_text("original")

        installer.restore_backup(pkg, snapshot)

        self.assertFalse(snapshot.exists())

    def test_restore_dry_run_changes_nothing(self):
        pkg = installer.Package("appb")
        snapshot = installer.BACKUP_ROOT / "appb" / "2020-01-01_00-00-00"
        snapshot.mkdir(parents=True)
        (snapshot / ".appbrc").write_text("original")

        installer.restore_backup(pkg, snapshot, dry_run=True)

        self.assertFalse((self.home / ".appbrc").exists())
        self.assertTrue((snapshot / ".appbrc").exists())

    def test_backup_round_trip_survives_install_and_uninstall(self):
        original = self.write_home(".appbrc", "hand written config")
        pkg = installer.Package("appb")

        with patched(installer, ask=lambda *a, **k: "b", run_stow=fake_stow(self)):
            self.assertTrue(installer.install_package(pkg))
        self.assertTrue(original.is_symlink())

        with patched(installer, confirm=lambda *a, **k: True,
                     run_stow=fake_stow(self)):
            self.assertTrue(installer.uninstall_package(installer.Package("appb")))

        self.assertFalse(original.is_symlink())
        self.assertEqual(original.read_text(), "hand written config")


class TestStowInvocation(InstallerTestCase):

    def test_command_line_shape(self):
        seen = {}

        def fake_run(cmd, **kwargs):
            seen["cmd"] = cmd
            return subprocess.CompletedProcess(cmd, 0, "", "")

        with patched(installer.subprocess, run=fake_run):
            self.assertTrue(installer.run_stow(["appa"]))

        self.assertEqual(seen["cmd"], [
            "stow", "--no-folding", "-d", str(self.repo), "-t", str(self.home),
            "appa",
        ])

    def test_delete_flag_is_passed_through(self):
        seen = {}

        def fake_run(cmd, **kwargs):
            seen["cmd"] = cmd
            return subprocess.CompletedProcess(cmd, 0, "", "")

        with patched(installer.subprocess, run=fake_run):
            installer.run_stow(["-D", "appa"])

        self.assertIn("-D", seen["cmd"])

    def test_dry_run_does_not_execute(self):
        def explode(*a, **k):
            raise AssertionError("subprocess.run must not be called on a dry run")

        with patched(installer.subprocess, run=explode):
            self.assertTrue(installer.run_stow(["appa"], dry_run=True))

    def test_failure_is_reported(self):
        def fake_run(cmd, **kwargs):
            return subprocess.CompletedProcess(cmd, 1, "", "stow: conflict")

        with patched(installer.subprocess, run=fake_run):
            self.assertFalse(installer.run_stow(["appa"]))


class TestConflictHandling(InstallerTestCase):

    def test_backup_choice_moves_file_then_stows(self):
        self.write_home(".appbrc", "original")
        pkg = installer.Package("appb")

        with patched(installer, ask=lambda *a, **k: "b", run_stow=fake_stow(self)):
            self.assertTrue(installer.install_package(pkg))

        self.assertTrue((self.home / ".appbrc").is_symlink())
        snapshots = installer.Package("appb").backups()
        self.assertEqual(len(snapshots), 1)
        self.assertEqual((snapshots[0] / ".appbrc").read_text(), "original")

    def test_overwrite_choice_discards_file(self):
        self.write_home(".appbrc", "original")
        pkg = installer.Package("appb")

        with patched(installer, ask=lambda *a, **k: "o", run_stow=fake_stow(self)):
            self.assertTrue(installer.install_package(pkg))

        self.assertTrue((self.home / ".appbrc").is_symlink())
        self.assertEqual(installer.Package("appb").backups(), [])

    def test_skip_choice_leaves_everything_alone(self):
        self.write_home(".appbrc", "original")
        pkg = installer.Package("appb")

        def must_not_run(*a, **k):
            raise AssertionError("stow must not run when the package is skipped")

        with patched(installer, ask=lambda *a, **k: "s", run_stow=must_not_run):
            self.assertTrue(installer.install_package(pkg))

        self.assertEqual((self.home / ".appbrc").read_text(), "original")

    def test_abort_choice_returns_none(self):
        self.write_home(".appbrc", "original")
        pkg = installer.Package("appb")

        with patched(installer, ask=lambda *a, **k: "a", run_stow=fake_stow(self)):
            self.assertIsNone(installer.install_package(pkg))

        self.assertEqual((self.home / ".appbrc").read_text(), "original")

    def test_clean_install_never_prompts(self):
        pkg = installer.Package("appb")

        def must_not_ask(*a, **k):
            raise AssertionError("no prompt expected without a conflict")

        with patched(installer, ask=must_not_ask, run_stow=fake_stow(self)):
            self.assertTrue(installer.install_package(pkg))

        self.assertTrue((self.home / ".appbrc").is_symlink())


class TestUninstall(InstallerTestCase):

    def test_removes_symlinks(self):
        self.link("appb", ".appbrc")
        pkg = installer.Package("appb")

        with patched(installer, run_stow=fake_stow(self)):
            self.assertTrue(installer.uninstall_package(pkg))

        self.assertFalse((self.home / ".appbrc").exists())

    def test_declining_restore_keeps_the_backup(self):
        self.link("appb", ".appbrc")
        snapshot = installer.BACKUP_ROOT / "appb" / "2020-01-01_00-00-00"
        snapshot.mkdir(parents=True)
        (snapshot / ".appbrc").write_text("original")

        with patched(installer, confirm=lambda *a, **k: False,
                     run_stow=fake_stow(self)):
            installer.uninstall_package(installer.Package("appb"))

        self.assertFalse((self.home / ".appbrc").exists())
        self.assertTrue((snapshot / ".appbrc").exists())

    def test_no_restore_prompt_without_a_backup(self):
        self.link("appb", ".appbrc")

        def must_not_ask(*a, **k):
            raise AssertionError("no restore prompt expected without a backup")

        with patched(installer, confirm=must_not_ask, run_stow=fake_stow(self)):
            installer.uninstall_package(installer.Package("appb"))

    def test_failure_is_propagated(self):
        self.link("appb", ".appbrc")
        with patched(installer, run_stow=lambda *a, **k: False):
            self.assertFalse(installer.uninstall_package(installer.Package("appb")))


class TestHelpers(InstallerTestCase):

    def test_tilde_abbreviates_home(self):
        self.assertEqual(installer.tilde(self.home / ".appbrc"), "~/.appbrc")

    def test_tilde_leaves_other_paths_alone(self):
        self.assertEqual(installer.tilde("/etc/hosts"), "/etc/hosts")

    def test_status_labels(self):
        self.assertIn("not installed", installer.Package("appb").status_label())
        self.link("appb", ".appbrc")
        self.assertIn("installed", installer.Package("appb").status_label())


class TestDependencyCheck(InstallerTestCase):

    def test_passes_when_stow_present(self):
        with patched(installer.shutil, which=lambda name: "/usr/bin/stow"):
            self.assertTrue(installer.ensure_dependencies())

    def test_fails_when_stow_and_brew_missing(self):
        with patched(installer.shutil, which=lambda name: None):
            self.assertFalse(installer.ensure_dependencies())

    def test_offers_brew_install_and_succeeds(self):
        calls = []
        found = {"stow": False}

        def which(name):
            if name == "brew":
                return "/opt/homebrew/bin/brew"
            return "/usr/bin/stow" if found["stow"] else None

        def fake_run(cmd, **kwargs):
            calls.append(cmd)
            found["stow"] = True
            return subprocess.CompletedProcess(cmd, 0)

        with patched(installer.shutil, which=which), \
                patched(installer.subprocess, run=fake_run), \
                patched(installer, confirm=lambda *a, **k: True):
            self.assertTrue(installer.ensure_dependencies())

        self.assertEqual(calls, [["/opt/homebrew/bin/brew", "install", "stow"]])

    def test_declining_brew_install_fails_the_check(self):
        def which(name):
            return "/opt/homebrew/bin/brew" if name == "brew" else None

        with patched(installer.shutil, which=which), \
                patched(installer, confirm=lambda *a, **k: False):
            self.assertFalse(installer.ensure_dependencies())


# --------------------------------------------------------------------------
# end-to-end tests (real script, real pty, stub stow)
# --------------------------------------------------------------------------

ANSI = re.compile(r"\x1b\[[0-9;?]*[a-zA-Z]")

KEYS = {"UP": "\x1b[A", "DOWN": "\x1b[B", "SPACE": " ", "ENTER": "\r"}


class Session:
    """Runs ./install under a pty so the checklist can be driven."""

    def __init__(self, argv, env, cwd):
        self.pid, self.fd = pty.fork()
        if self.pid == 0:  # child
            os.chdir(str(cwd))
            os.execvpe(argv[0], argv, env)
        self.raw = ""

    @property
    def text(self):
        return ANSI.sub("", self.raw).replace("\r", "")

    def _pump(self, timeout=0.25):
        """Read whatever is available. Returns False once the pty hits EOF,
        which happens when the child exits."""
        ready, _, _ = select.select([self.fd], [], [], timeout)
        if not ready:
            return True  # nothing yet, but the child is still going
        try:
            data = os.read(self.fd, 65536)
        except OSError:  # macOS/Linux raise EIO on the far end closing
            return False
        if not data:
            return False
        self.raw += data.decode("utf-8", "replace")
        return True

    def expect(self, needle, timeout=15):
        deadline = time.time() + timeout
        while needle not in self.text:
            if time.time() > deadline:
                raise AssertionError(
                    f"timed out waiting for {needle!r}\n--- saw ---\n{self.text}")
            if not self._pump():
                # Child exited; the text either arrived with it or never will.
                if needle not in self.text:
                    raise AssertionError(
                        f"child exited before {needle!r}\n--- saw ---\n{self.text}")
        return self

    def send(self, *keys):
        for key in keys:
            os.write(self.fd, KEYS.get(key, key).encode())
        return self

    def wait(self, timeout=15):
        """Drain output until the child exits, then return its exit status."""
        deadline = time.time() + timeout
        alive = True
        while time.time() < deadline:
            if not self._pump():
                alive = False
                break
        if alive:  # never saw EOF, so something is stuck
            os.kill(self.pid, signal.SIGKILL)
        _, status = os.waitpid(self.pid, 0)
        return os.WEXITSTATUS(status) if os.WIFEXITED(status) else -1


class EndToEndTestCase(InstallerTestCase):
    """Copies the script into a scratch repo so the fixtures are self-contained."""

    def setUp(self):
        super().setUp()
        shutil.copy(INSTALL_SCRIPT, self.repo / "install")
        os.chmod(self.repo / "install", 0o755)

        self.bin = self.tmp / "bin"
        self.bin.mkdir()
        stub = self.bin / "stow"
        stub.write_text(STUB_STOW)
        os.chmod(stub, 0o755)

        self.env = dict(os.environ)
        self.env.update({
            "HOME": str(self.home),
            "PATH": f"{self.bin}:{self.env.get('PATH', '')}",
            "NO_COLOR": "1",          # keep assertions readable
            "TERM": "dumb",
        })

    def run_installer(self, *args):
        return Session([str(self.repo / "install"), *args], self.env, self.repo)


class TestEndToEnd(EndToEndTestCase):

    def test_status_lists_every_package(self):
        session = self.run_installer("--status")
        session.wait()
        for name in ("appa", "appb", "appc"):
            self.assertIn(name, session.text)
        self.assertIn("not installed", session.text)

    def test_status_reflects_installed_packages(self):
        self.link("appb", ".appbrc")
        session = self.run_installer("--status")
        session.wait()
        self.assertRegex(session.text, r"appb\s+installed")

    def test_install_via_checklist(self):
        session = self.run_installer()
        session.expect("q quit")
        session.send("SPACE", "ENTER")          # tick appa, apply
        session.expect("Apply these changes?")
        session.send("y", "ENTER")
        session.expect("Done.")
        self.assertEqual(session.wait(), 0)

        link = self.home / ".config/appa/appa.conf"
        self.assertTrue(link.is_symlink())
        self.assertEqual(link.resolve(),
                         (self.repo / "appa/.config/appa/appa.conf").resolve())

    def test_quitting_changes_nothing(self):
        session = self.run_installer()
        session.expect("q quit")
        session.send("SPACE", "q")
        self.assertEqual(session.wait(), 130)
        self.assertIn("Cancelled", session.text)
        self.assertFalse((self.home / ".config/appa").exists())

    def test_installed_packages_start_checked(self):
        self.link("appb", ".appbrc")
        session = self.run_installer()
        session.expect("q quit")
        session.expect("no changes")            # nothing pending on entry
        session.send("q")
        session.wait()

    def test_conflict_is_backed_up_then_linked(self):
        target = self.write_home(".appbrc", "hand written")
        session = self.run_installer()
        session.expect("q quit")
        session.send("DOWN", "SPACE", "ENTER")  # tick appb
        session.expect("Apply these changes?")
        session.send("y", "ENTER")
        session.expect("What should happen?")
        session.send("b", "ENTER")
        session.expect("Done.")
        self.assertEqual(session.wait(), 0)

        self.assertTrue(target.is_symlink())
        snapshots = installer.Package("appb").backups()
        self.assertEqual(len(snapshots), 1)
        self.assertEqual((snapshots[0] / ".appbrc").read_text(), "hand written")

    def test_uninstall_restores_backup(self):
        self.link("appb", ".appbrc")
        snapshot = installer.BACKUP_ROOT / "appb" / "2020-01-01_00-00-00"
        snapshot.mkdir(parents=True)
        (snapshot / ".appbrc").write_text("hand written")

        session = self.run_installer()
        session.expect("q quit")
        session.send("DOWN", "SPACE", "ENTER")  # untick appb
        session.expect("Apply these changes?")
        session.send("y", "ENTER")
        session.expect("Restore it?")
        session.send("y", "ENTER")
        session.expect("Done.")
        self.assertEqual(session.wait(), 0)

        restored = self.home / ".appbrc"
        self.assertFalse(restored.is_symlink())
        self.assertEqual(restored.read_text(), "hand written")

    def test_dry_run_touches_nothing(self):
        session = self.run_installer("--dry-run")
        session.expect("q quit")
        session.send("SPACE", "ENTER")
        session.expect("Apply these changes?")
        session.send("y", "ENTER")
        session.expect("Done.")
        session.wait()

        self.assertIn("would install", session.text)
        self.assertFalse((self.home / ".config/appa").exists())

    def test_select_all_then_none(self):
        session = self.run_installer()
        session.expect("q quit")
        session.send("a")
        session.expect("+3 install")
        session.send("n")
        session.expect("no changes")
        session.send("q")
        session.wait()

    def test_non_tty_falls_back_to_status(self):
        result = subprocess.run(
            [str(self.repo / "install")],
            env=self.env, cwd=str(self.repo),
            stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=30,
        )
        self.assertEqual(result.returncode, 0)
        self.assertIn("appa", result.stdout)
        self.assertFalse((self.home / ".config/appa").exists())

    def test_missing_stow_is_reported(self):
        (self.bin / "stow").unlink()
        env = dict(self.env)
        env["PATH"] = "/usr/bin:/bin"           # no stow, no brew
        session = Session([str(self.repo / "install")], env, self.repo)
        self.assertEqual(session.wait(), 1)
        self.assertIn("stow is not installed", session.text)


# --------------------------------------------------------------------------
# small helpers
# --------------------------------------------------------------------------

class patched:
    """Temporarily swap attributes on an object. Avoids a unittest.mock import
    and keeps the call sites short."""

    def __init__(self, target, **attrs):
        self.target = target
        self.attrs = attrs
        self.saved = {}

    def __enter__(self):
        for name, value in self.attrs.items():
            self.saved[name] = getattr(self.target, name)
            setattr(self.target, name, value)
        return self.target

    def __exit__(self, *exc):
        for name, value in self.saved.items():
            setattr(self.target, name, value)
        return False


def fake_stow(case):
    """A run_stow replacement that performs the symlinking in-process."""

    def run(args, dry_run=False):
        delete = "-D" in args
        for name in (a for a in args if not a.startswith("-")):
            pkg = installer.Package(name)
            for rel in pkg.entries:
                source, target = pkg.path / rel, pkg.target(rel)
                if delete:
                    if target.is_symlink():
                        target.unlink()
                elif not (target.exists() or target.is_symlink()):
                    target.parent.mkdir(parents=True, exist_ok=True)
                    target.symlink_to(source)
                else:
                    return False
        return True

    return run


if __name__ == "__main__":
    # Quieten the script's own output; the tests assert on behaviour, not prints.
    unittest.main(verbosity=2, buffer=True)
