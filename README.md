# Dotfiles

Flake-based NixOS, nix-darwin, and Home Manager configuration built from a shared host inventory.

## Quick start

### WSL NixOS installation

1. Enable WSL and install NixOS by following the [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) setup guide.
2. Download and run the bootstrap script from your home directory.

```bash
cd
curl https://raw.githubusercontent.com/wq-chang/dotfiles/refs/heads/master/scripts/wsl_init.sh -o wsl_init.sh
source wsl_init.sh
```

3. Restart NixOS from Windows Terminal so the username change takes effect.

```bash
wsl -t NixOS
wsl -d NixOS --user root exit
wsl -t NixOS
```

4. Move `dotfiles` into the home directory and clean up the default user directory.

```bash
curl -sSL https://raw.githubusercontent.com/wq-chang/dotfiles/refs/heads/master/scripts/wsl_post_init.sh | bash
```

5. Start using the WSL environment.

```bash
wsl
```

### Updating the WSL host

```bash
cd ~/dotfiles
nixos-rebuild switch --flake .#<host> --sudo
```

## Repository layout

| Path                                    | Purpose                                                                                                                                                                                                           |
| --------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `flake.nix`                             | Main entrypoint. Builds `nixosConfigurations`, `darwinConfigurations`, and `homeConfigurations` from `hosts/default.nix`, and passes shared special args such as `customPkgs`, `isHm`, `isNixOs`, and `isDarwin`. |
| `hosts/default.nix`                     | Host inventory with each machine's kind, system, state versions, and module paths.                                                                                                                                |
| `hosts/common/home.nix`                 | Shared Home Manager defaults.                                                                                                                                                                                     |
| `hosts/<host>/configuration.nix`        | System-only overrides for a host.                                                                                                                                                                                 |
| `hosts/<host>/home.nix`                 | Host-specific Home Manager configuration.                                                                                                                                                                         |
| `hosts/<host>/module-configuration.nix` | Module toggles shared by the host's system and Home Manager graphs.                                                                                                                                               |
| `modules/`                              | Reusable modules imported into both the system and Home Manager graphs.                                                                                                                                           |
| `packages/default.nix`                  | Auto-loads `packages/*.nix` into `customPkgs`.                                                                                                                                                                    |
| `overlays/default.nix`                  | Auto-loads overlay files from `overlays/*.nix` and passes `deps`/`depsLock` into them.                                                                                                                            |
| `lib/deps.nix`                          | Reads `deps-lock.json` and resolves `git`, `github-release`, `pypi`, and `npm` dependencies.                                                                                                                      |
| `bin/mdep`                              | Updates `deps-lock.json`.                                                                                                                                                                                         |

## Common workflows

### Adding a new host

1. Add the host's user settings to the external `dotfilesConfigs` input so the key in `hosts/default.nix` resolves to a real config.
2. Create `hosts/<name>/configuration.nix`, `hosts/<name>/home.nix`, and `hosts/<name>/module-configuration.nix`.
3. Register the host in `hosts/default.nix`.

### Host examples

#### Linux / NixOS

```nix
{
  wsl = {
    kind = "nixos";
    system = "x86_64-linux";
    systemStateVersion = "24.05";
    homeStateVersion = "24.05";
    enableWsl = true;
    systemModule = ./laptop/configuration.nix;
    homeModule = ./laptop/home.nix;
    moduleConfig = ./laptop/module-configuration.nix;
  };
}
```

Apply it with:

```bash
nixos-rebuild switch --flake .#wsl --sudo
```

#### macOS / nix-darwin

```nix
{
  macbook = {
    kind = "darwin";
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

`flake.nix` exposes `darwinConfigurations` through `nix-darwin`, so Linux and macOS hosts follow the same inventory pattern.

## Packages, overlays, and dependencies

### `customPkgs` and overlays

```nix
{
  home.packages = [
    customPkgs.aws-local
  ];
}
```

- `customPkgs` is generated from `packages/*.nix`.
- `customPkgs` exposes hyphenated package names that match file names, for example `customPkgs.aws-local`.
- `flake.nix` wires `customPkgs` into module arguments separately from nixpkgs overlays.
- Overlay files in `overlays/*.nix` are auto-loaded into `pkgs`.
- Repo overlays use the signature `{ deps, depsLock, lib, ... }: final: prev: { ... }`.
- `overlays/github-copilot-cli.nix` is the reference example for tracking a newer upstream GitHub release than nixpkgs currently provides.

### `mdep`

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

## Command reference

| Command                                                            | Purpose                                                |
| ------------------------------------------------------------------ | ------------------------------------------------------ |
| `nix flake check --no-build --quiet`                               | Validate the flake without building.                   |
| `nix build .#nixosConfigurations.wsl.config.system.build.toplevel` | Build the WSL NixOS system closure.                    |
| `nix eval .#darwinConfigurations`                                  | Inspect available nix-darwin outputs without building. |
| `nix build .#darwinConfigurations.<host>.activationPackage`        | Build a darwin activation package without applying it. |
| `home-manager build --flake .#wsl`                                 | Build the WSL Home Manager profile.                    |
| `mdep update`                                                      | Refresh and re-lock `deps-lock.json`.                  |
| `upcmp`                                                            | Parse man pages and convert them to zsh completions.   |
