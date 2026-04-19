## WSL NixOS

### Installation

1. Enable WSL and install NixOS, refer to the steps through the [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
2. Use curl to download `wsl_init.sh` and run it from the home directory

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
2. Evaluate or build the flake

```bash
cd ~/dotfiles
nix flake check --no-build --quiet
nix build .#nixosConfigurations.wsl.config.system.build.toplevel
nixos-rebuild switch --flake .#wsl --sudo
```

## Structure

- Register hosts in `hosts/default.nix`.
- `kind = "nixos"` hosts build under `nixosConfigurations`; `kind = "darwin"` hosts build under `darwinConfigurations`.
- Shared Home Manager defaults live in `hosts/common/home.nix`.
- Add reusable modules under `modules/`.
- Add custom packages under `packages/` and consume them through `customPkgs`.
- Drop overlays into `overlays/*.nix`; they are loaded automatically.

## Adding a new host

1. Add the host's user settings to your external `dotfilesConfigs` input so `configKey` resolves to a real config.
2. Create `hosts/<name>/configuration.nix`, `hosts/<name>/home.nix`, and `hosts/<name>/module-configuration.nix`.
3. Register the host in `hosts/default.nix`.

### Linux / NixOS host example

```nix
{
  laptop = {
    kind = "nixos";
    configKey = "laptop";
    system = "x86_64-linux";
    systemStateVersion = "24.05";
    homeStateVersion = "24.05";
    systemModule = ./laptop/configuration.nix;
    homeModule = ./laptop/home.nix;
    moduleConfig = ./laptop/module-configuration.nix;
  };
}
```

Apply it with:

```bash
nixos-rebuild switch --flake .#laptop --sudo
```

### macOS / nix-darwin host example

```nix
{
  macbook = {
    kind = "darwin";
    configKey = "macbook";
    system = "aarch64-darwin";
    homeStateVersion = "24.05";
    systemModule = ./macbook/configuration.nix;
    homeModule = ./macbook/home.nix;
    moduleConfig = ./macbook/module-configuration.nix;
  };
}
```

Apply it with:

```bash
darwin-rebuild switch --flake .#macbook
```

`flake.nix` now exposes `darwinConfigurations` through `nix-darwin`, so Linux and macOS hosts share the same inventory pattern.

## Utils

### mdep (Add/update locked dependencies)

```bash
# Add a git dependency to deps-lock.json
mdep add <name> <repo-url> -t git -b <branch> -r <commit revision> -s <sparse checkout1> <sparse checkout2>

# Add a GitHub release dependency from the source archive
mdep add <name> <repo-url> -t github-release --tag <tag>

# Add a GitHub release dependency with per-system assets
mdep add github-copilot-cli https://github.com/github/copilot-cli -t github-release \
  --asset-pattern 'x86_64-linux=^copilot-linux-x64\.tar\.gz$' \
  --asset-pattern 'aarch64-linux=^copilot-linux-arm64\.tar\.gz$' \
  --asset-pattern 'x86_64-darwin=^copilot-darwin-x64\.tar\.gz$' \
  --asset-pattern 'aarch64-darwin=^copilot-darwin-arm64\.tar\.gz$'

# Add a PyPI dependency (uses the latest version when --version is omitted)
mdep add <name> <package-name> -t pypi --version <version>

# Add an npm dependency (uses the latest version when --version is omitted)
mdep add <name> <package-name> -t npm --version <version>

# Update dependencies in deps-lock.json
mdep update
```

Asset-based `github-release` entries keep one dependency record, store the resolved `assets.<system>` URLs and hashes, and let Nix select the correct asset from the current `host.system`.

### customPkgs and overlays

```nix
{
  home.packages = [
    customPkgs.aws-local
  ];
}
```

- `customPkgs` is generated from `packages/*.nix`.
- `customPkgs` exposes hyphenated package names that match file names, e.g., `customPkgs.aws-local`
- Overlay files in `overlays/*.nix` are auto-loaded into `pkgs`.
- Repo overlays can use the signature `{ deps, depsLock, lib, ... }: final: prev: { ... }`.
- `overlays/github-copilot-cli.nix` is the reference example for tracking a newer upstream GitHub release than nixpkgs currently provides.

### upcmp (Parse man pages and convert to zsh completions)

```bash
upcmp
```
