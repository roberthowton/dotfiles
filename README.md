# .files

## Instructions

### Install from Brewfile

1. Ensure `brew` is installed

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. `cd` to `brewfiles/personal` or `brewfiles/work`

3. Install from `Brewfile`

```shell
brew bundle
```

### Install dotfiles

1. Ensure `stow` is installed.

```shell
brew install stow
```

2. Clone repo to `~/dotfiles`

3. Run `stow`

```shell
cd ~/dotfiles
stow .
```
