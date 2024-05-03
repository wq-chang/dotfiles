## Non NixOs

### Installation

```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
git@github.com:wq-chang/dotfiles.git
nix build
python scripts/create_dotfiles_config.py
```

### Switch

```
home-manager switch --flake ./.#<host>
```

### Add Github Dependencies

```
python scripts/manage_dependencies.py add <name> <url> -b <branch> -r <commit hash> -s <path 1> <path 2> <path n>
python scripts/manage_dependencies.py update
```
