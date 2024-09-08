## WSL NixOs

### Installation

1. Enable WSL and install NixOs, refer to the steps through the [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
2. Build NixOs flake

```bash
sudo nixos-rebuild boot --flake github:wq-chang/dotfiles/master#wsl
```

3. Follow the steps in [change username guide](https://github.com/nix-community/NixOS-WSL/blob/main/docs/src/how-to/change-username.md) to apply the username

### Update dotfiles config

1. Clone dotfiles to home directory

```bash
git clone git@github.com:wq-chang/dotfiles.git ~/
```

2. Modify dotfiles
3. Build NixOs flake

```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#wsl
```

## Utils

### mdep (Add/update Github Dependencies)

```bash
# Add dependencies to deps-lock.json
# Flags are optional
# -b / --branch - default to master/main
# -r / --rev - default to latest commit revision
# -s / --sparse-checkout -- Accept more than 1 arguments, separate by space
mdep add <name> <dependency url> -b <branch> -r <commit revision> -s <sparse checkout1> <sparse checkout2>

# Update dependencies in deps-lock.json
mdep update
```

### upcmp (Parse man pages and convert to zsh completions)

```bash
upcmp
```
