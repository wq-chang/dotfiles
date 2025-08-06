## WSL NixOS

### Installation

1. Create `%USERPROFILE%/.wslconfig` and paste the following into it

```
[wsl2]
kernelCommandLine = cgroup_no_v1=all
```

2. Enable WSL and install NixOS, refer to the steps through the [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
3. Use curl to download `wsl_init.sh` and run it from the home directory

```bash
cd
curl https://raw.githubusercontent.com/wq-chang/dotfiles/refs/heads/master/scripts/wsl_init.sh -o wsl_init.sh
source wsl_init.sh
```

4. Run the following commands in Windows Terminal to apply the username change

```bash
wsl -t NixOS
wsl -d NixOS --user root exit
wsl -t NixOS
```

5. Move `dotfiles` to the home directory and clean up default user directory

```bash
curl -sSL https://raw.githubusercontent.com/wq-chang/dotfiles/refs/heads/master/scripts/wsl_post_init.sh | bash
```

6. Start the WSL and start using NixOS

```bash
wsl
```

### Update dotfiles config

1. Modify dotfiles
2. Build NixOS flake

```bash
cd ~/dotfiles
nixos-rebuild switch --flake .#wsl --sudo
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
