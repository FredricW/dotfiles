           /$$             /$$      /$$$$$$  /$$ /$$
          | $$            | $$     /$$__  $$|__/| $$
      /$$$$$$$  /$$$$$$  /$$$$$$  | $$  \__/ /$$| $$  /$$$$$$   /$$$$$$$
     /$$__  $$ /$$__  $$|_  $$_/  | $$$$    | $$| $$ /$$__  $$ /$$_____/
    | $$  | $$| $$  \ $$  | $$    | $$_/    | $$| $$| $$$$$$$$|  $$$$$$
    | $$  | $$| $$  | $$  | $$ /$$| $$      | $$| $$| $$_____/ \____  $$
    |  $$$$$$$|  $$$$$$/  |  $$$$/| $$      | $$| $$|  $$$$$$$ /$$$$$$$/
     \_______/ \______/    \___/  |__/      |__/|__/ \_______/|_______/

# My Dotfiles collection

## Install

Clone repo into user folder

```sh
git clone git@github.com:FredricW/dotfiles.git ~/dotfiles
```

Then run the installer

```sh
cd ~/dotfiles/
./install
```

It checks that `stow` is present (offering to `brew install` it if not), then shows a
checklist of every config in the repo. Configs that are already installed start out
checked — tick one to install it, untick one to remove it.

- If a real file is already sitting where a config wants to go, you're asked whether to
  back it up, overwrite it, skip that config, or abort.
- Backups land in `~/.dotfiles-backups/<config>/<timestamp>/`, mirroring their original
  paths.
- When removing a config that has a backup, you're offered the chance to restore it.

| flag | |
|---|---|
| `--status` | print what's installed and exit |
| `--dry-run` | show what would happen, change nothing |

### Doing it by hand

The installer is just a wrapper around stow, so this still works:

```sh
cd ~/dotfiles/
stow neovim --no-folding
```

> `--no-folding` means that no folders will be symlinked, only the files.
> If a tree is symlinked (meaning a folder is symlinked), then new files
> and folders added by other programs will be adopted into the stow directory
> and tracked (which we usually don't want for dotfiles).

Or install all of them

```sh
stow /* --no-folding
```

## Remove a config

```sh
stow neovim -D --no-folding
```

## Add new files / create a new config

A config is just the top level folders within the stow directory (which in this case
is the root of the repo). So to track the config of a new program, simply create
a new folder with its name:

```sh
mkdir ~/dotfiles/lunarvim
```

Then move the configuration files from their original location, to their **equivalent location**
within the newly added config (`~/dotfiles/lunarvim/`) folder:

```sh
mv ~/.config/lvim/config.lua ~/dotfiles/lunarvim/.config/lvim/config.lua
```

Then add symlinks back with stow

```sh
stow lunarvim --no-folding
```

**It is important that the path is exactly the same! All that is different is where it begins.**
