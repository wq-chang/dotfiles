# Repository guide

## Layout

- `flake.nix` is the main entrypoint and builds `nixosConfigurations`, `darwinConfigurations`, and `homeConfigurations` from the host inventory in `hosts/default.nix`.
- `hosts/default.nix` declares each host's kind, system, state versions, and host-specific modules.
- `hosts/common/home.nix` contains shared Home Manager defaults.
- `hosts/<host>/configuration.nix` contains system-only overrides for that host, whether the host is NixOS or nix-darwin.
- `hosts/<host>/home.nix` contains Home Manager packages and host-specific user config.
- `hosts/<host>/module-configuration.nix` toggles the shared modules for both NixOS and Home Manager.
- `modules/` contains reusable modules that are imported into both the NixOS and Home Manager graphs.
- `lib/deps.nix` reads `deps-lock.json` and dispatches source fetching for `git`, `github-release`, `pypi`, and `npm`, including per-system GitHub release assets.
- `packages/default.nix` auto-loads `packages/*.nix` into `customPkgs`.
- `flake.nix` imports `packages/default.nix`, passes `customPkgs` plus shared special args (`isHm`, `isNixOs`, `isDarwin`), and builds the shared host context.
- `overlays/default.nix` auto-loads every overlay in `overlays/*.nix` and passes `deps`/`depsLock` into repo overlays.
- `bin/mdep` updates `deps-lock.json`.

## Conventions

- Add a new machine by registering it in `hosts/default.nix`; the flake builders pick up the rest from there.
- `kind = "nixos"` hosts build under `nixosConfigurations`; `kind = "darwin"` hosts build under `darwinConfigurations`.
- Keep host files focused on overrides. Shared imports belong in the flake builders or `hosts/common/`.
- When a change affects repository structure, setup/usage, conventions, or contributor workflow, update both `README.md` and `AGENTS.md` in the same change so the docs match the codebase.
- Put custom packages in `packages/*.nix` and consume them through `customPkgs`.
- For platform-aware module logic, use the shared special args from `flake.nix` (`isHm`, `isNixOs`, `isDarwin`) instead of recomputing platform checks inside modules.
- `customPkgs` exposes hyphenated package names that match file names, e.g., `customPkgs.aws-local`
- Drop overlays into `overlays/*.nix` as functions of the form `{ deps, depsLock, lib, ... }: final: prev: { ... }`; they are loaded automatically.
- Use explicit dependency `type` values in `deps-lock.json` and let `mdep` manage `rev`, `tag`, `version`, `url`, and `hash`.
- Asset-based `github-release` dependencies store an `assetPatterns` map plus resolved `assets.<system>` entries; Nix selects the current asset from `host.system`.
- `overlays/github-copilot-cli.nix` is the reference example for consuming a per-system GitHub release dependency from an overlay.

## Useful commands

- `nix flake check --no-build --quiet` — Validate the flake (evaluate inputs and perform basic checks) without building; quick way to catch evaluation-time errors.
- `nix build .#nixosConfigurations.wsl.config.system.build.toplevel` — Build the NixOS system generation (toplevel) for the wsl host; produces the system closure to deploy with nixos-rebuild.
- `nix eval .#darwinConfigurations` — Evaluate and print the flake output for darwinConfigurations (no build); useful to inspect available outputs.
- `nix build .#darwinConfigurations.<host>.activationPackage` — Build the darwin activation package for `<host>` without applying it (recommended when you don't want the configuration to be auto-applied).
- `home-manager build --flake .#wsl` — Build the Home Manager user profile for the wsl host; results/ contains an activation script to apply.
- `mdep update` — Refresh and re-lock dependencies in deps-lock.json (recomputes hashes and updates locked assets/versions where applicable).
