# My Dotfiles collection

## Install

Clone repo into user folder

```sh
git clone git@github.com:FredricW/dotfiles.git ~/dotfiles
```

"Install" the desired configs

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
