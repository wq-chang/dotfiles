# Repository Guide for AI Assistants

This guide is designed to help AI code generation assistants (like GitHub Copilot, Claude, etc.) understand the repository structure and conventions. For human-readable setup instructions, see [README.md](README.md).

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│ flake.nix (main entrypoint)                             │
│ ├─ Reads hosts/default.nix (host inventory)             │
│ ├─ Imports lib/deps.nix (dependency resolver)           │
│ └─ Builds configs via flake outputs                     │
├─────────────────────────────────────────────────────────┤
│ Host Configuration (system-specific)                    │
│ └─ hosts/<host>/{configuration.nix, home.nix}           │
├─────────────────────────────────────────────────────────┤
│ Shared Modules (cross-platform)                         │
│ └─ modules/ (imported into system + Home Manager)       │
├─────────────────────────────────────────────────────────┤
│ Custom Packages & Overlays                              │
│ ├─ packages/*.nix → auto-loaded as customPkgs           │
│ └─ overlays/*.nix → auto-loaded into pkgs               │
├─────────────────────────────────────────────────────────┤
│ Dependency Management                                   │
│ ├─ deps-lock.json (locked versions)                     │
│ └─ bin/mdep (update tool)                               │
└─────────────────────────────────────────────────────────┘
```

---

## Key Terms

- **Toplevel**: The NixOS system generation closure (complete system configuration). Built with `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- **Activation package**: The nix-darwin equivalent of a toplevel—a package that activates the system configuration when run.
- **Module**: A reusable Nix configuration unit in `modules/` that's imported into both NixOS/nix-darwin and Home Manager. Receives shared special args: `isHm` (bool), `isNixOs` (bool), `isDarwin` (bool).
- **Special args**: Context passed to all modules from `flake.nix`, including `customPkgs`, platform flags (`isHm`, `isNixOs`, `isDarwin`), and flake inputs.
- **customPkgs**: Auto-loaded custom packages from `packages/*.nix`, exposed with hyphenated names matching file names (e.g., `customPkgs.aws-local` from `packages/aws-local.nix`).

---

## File Structure

| Path                                    | Purpose                                                                                                                                                                                                                                                            |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --- |
| `flake.nix`                             | Main entrypoint. Reads `hosts/default.nix`, imports modules, and exposes `nixosConfigurations`, `darwinConfigurations`, `homeConfigurations` outputs. Passes shared special args (`customPkgs`, `isHm`, `isNixOs`, `isDarwin`, `deps`, `depsLock`) to all modules. |
| `hosts/default.nix`                     | Host inventory. Each host defines: `kind` (nixos or darwin), `system` (x86_64-linux, aarch64-darwin, etc.), state versions, and module paths. The flake auto-discovers and builds all registered hosts.                                                            |
| `hosts/<host>/configuration.nix`        | System-level overrides for a specific host (NixOS/nix-darwin only). Imports shared modules via `module-configuration.nix` and applies host-specific settings.                                                                                                      |
| `hosts/<host>/home.nix`                 | Home Manager config for a host. Defines user packages, shell config, tools. Imported alongside system config.                                                                                                                                                      |
| `hosts/<host>/module-configuration.nix` | Module toggles shared between system and Home Manager graphs for this host. Determines which modules in `modules/` are active and with what settings.                                                                                                              |
| `hosts/common/home.nix`                 | Shared Home Manager defaults applied to all hosts.                                                                                                                                                                                                                 |
| `modules/`                              | Reusable modules for both NixOS/nix-darwin and Home Manager (cross-platform). Each module receives shared special args. Use `isHm`, `isNixOs`, `isDarwin` to branch platform-specific logic; don't recompute platform checks.                                      |
| `packages/default.nix`                  | Auto-loads every `.nix` file from `packages/` and exposes them as `customPkgs` with hyphenated names.                                                                                                                                                              |
| `packages/<name>.nix`                   | Custom package definition. Consumed as `customPkgs.<name>` (e.g., `packages/aws-local.nix` → `customPkgs.aws-local`).                                                                                                                                              |
| `overlays/default.nix`                  | Auto-loads all overlay files from `overlays/` and injects them into nixpkgs, receiving `deps`, `depsLock`, and other special args.                                                                                                                                 |
| `overlays/<name>.nix`                   | Overlay file. Must be a function with signature `{ deps, depsLock, lib, ... }: final: prev: { ... }`. Auto-loaded by `overlays/default.nix`.                                                                                                                       |
| `lib/deps.nix`                          | Reads `deps-lock.json` and resolves dependencies (git, github-release, pypi, npm). Handles per-system asset selection for github-release types.                                                                                                                    |
| `bin/mdep`                              | CLI tool to manage `deps-lock.json`. Add, remove, and lock dependencies (git, github-release, pypi, npm). Supports `npmDepsHash` auto-computation for packages with npm lockfiles.                                                                                 |     |
| `deps-lock.json`                        | Locked versions of all external dependencies. Use explicit `type` values; let `mdep` manage `rev`, `tag`, `version`, `url`, `hash`.                                                                                                                                |

---

## Host Registration Workflow

To add a new host, follow these steps in order:

1. **Register in `hosts/default.nix`**:

   ```nix
   {
     my-host = {
       kind = "nixos";  # or "darwin"
       system = "x86_64-linux";  # or "aarch64-darwin"
       systemStateVersion = "24.05";
       homeStateVersion = "24.05";
       systemModule = ./my-host/configuration.nix;
       homeModule = ./my-host/home.nix;
       moduleConfig = ./my-host/module-configuration.nix;
     };
   }
   ```

   **Why**: `flake.nix` iterates over all hosts in this file and auto-discovers them.

2. **Create host files**:
   - `hosts/my-host/configuration.nix` (system config, empty is fine for minimal setup)
   - `hosts/my-host/home.nix` (Home Manager config, empty is fine)
   - `hosts/my-host/module-configuration.nix` (module toggles, empty is fine)

3. **Build and verify** (before applying):

   ```bash
   # Build without applying (safe verification step)
   nixos-rebuild build --flake .#my-host  # for NixOS
   # or
   darwin-rebuild build --flake .#my-host  # for darwin

   # Inspect the result before committing to the system
   ```

   **Safety note**: Always use `build` first to verify the configuration. Only apply with `switch` after confirming the build is correct.

---

## Platform-Aware Module Logic

When writing modules in `modules/`, use the shared special args to branch logic instead of recomputing platform checks:

**Correct (use special args):**

```nix
{ isHm, isNixOs, isDarwin, ... }:
{
  config = {
    # Home Manager only
    home.packages = if isHm then [ ... ] else [];

    # NixOS only
    environment.systemPackages = if isNixOs then [ ... ] else [];
  };
}
```

**Incorrect (don't recompute):**

```nix
{ pkgs, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;  # ❌ Redundant; use isDarwin from special args
in
{ ... }
```

---

## customPkgs: Defining and Consuming

### Defining a custom package

Create `packages/my-tool.nix`:

```nix
{ lib, stdenv, fetchFromGitHub, ... }:
stdenv.mkDerivation {
  pname = "my-tool";
  version = "1.0.0";
  # ... build logic
}
```

The package is automatically exposed as `customPkgs.my-tool` (hyphenated name matching file name).

### Consuming customPkgs in modules

```nix
{ customPkgs, ... }:
{
  home.packages = [ customPkgs.my-tool ];
}
```

**Important**: Always use `customPkgs` via the special args, not via direct imports.

---

## Overlays: Pattern and Integration

### Structure

Create `overlays/my-overlay.nix`:

```nix
{ deps, depsLock, lib, ... }: final: prev:
{
  my-package = final.callPackage ../packages/my-package.nix { };

  upstream-package = prev.upstream-package.overrideAttrs (oldAttrs: {
    version = "2.0.0";
  });
}
```

**Signature**: `{ deps, depsLock, lib, ... }: final: prev: { ... }`

- `deps`: Resolved dependencies from `lib/deps.nix`
- `depsLock`: Raw `deps-lock.json` data
- `final`: The result nixpkgs with all overlays applied so far
- `prev`: The incoming nixpkgs (before this overlay)

The overlay is automatically loaded by `overlays/default.nix`.

### Reference examples

- **`overlays/github-copilot-cli.nix`** — consuming per-system GitHub release assets.
- **`overlays/pi-coding-agent.nix`** — overriding a nixpkgs package from a `github-release` source with auto-computed `npmDepsHash`.

---

## Dependencies: Types and Management

### Dependency types

**Git dependencies** (track branch or commit):

```json
{
  "type": "git",
  "repo": "https://github.com/owner/repo",
  "rev": "abc123",
  "sparse": ["path/to/checkout"]
}
```

**GitHub release** (source archive):

```json
{
  "type": "github-release",
  "repo": "https://github.com/owner/repo",
  "tag": "v1.0.0"
}
```

**GitHub release with system-specific and universal assets**:

```json
{
  "type": "github-release",
  "repo": "https://github.com/owner/repo",
  "tag": "v1.0.0",
  "assetPatterns": {
    "universal": "^tool-[0-9.]+\\.tgz$",
    "x86_64-linux": "^tool-linux-x64\\.tar\\.gz$"
  },
  "assets": {
    "universal": { "url": "...", "hash": "..." },
    "x86_64-linux": { "url": "...", "hash": "..." }
  }
}
```

Nix selects `assets.<host.system>` when present and otherwise falls back to `assets.universal`.

**PyPI dependencies**:

```json
{
  "type": "pypi",
  "version": "1.2.3"
}
```

**npm dependencies**:

```json
{
  "type": "npm",
  "version": "1.2.3"
}
```

**Optional fields** (any type that produces a source tree):

| Field             | Type   | Description                                                                                                                                                                    |
| ----------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `npmDepsHash`     | string | SRI hash computed by `nix run nixpkgs#prefetch-npm-deps` on the dependency's lockfile. Set automatically by `mdep add --npm-deps-lock-path`.                                   |
| `npmDepsLockPath` | string | Path to the npm lockfile within the extracted source tree (e.g. `packages/coding-agent/package-lock.json`). Used by `mdep update` to recompute `npmDepsHash` on version bumps. |

When both fields are present in `deps-lock.json`, the overlay reads `npmDepsHash` directly (see `overlays/pi-coding-agent.nix` for the pattern).

### Managing dependencies

```bash
# Add a git dependency
mdep add my-tool https://github.com/owner/repo -t git -b main

# Add a GitHub release dependency
mdep add my-tool https://github.com/owner/repo -t github-release --tag v1.0.0

# Add a GitHub release with a universal asset
mdep add github-copilot-cli https://github.com/github/copilot-cli -t github-release \
  --asset-pattern 'universal=^github-copilot-[0-9.]+\.tgz$'

# Add a GitHub release dependency with npm lockfile tracking
mdep add pi-coding-agent https://github.com/earendil-works/pi -t github-release \
  --npm-deps-lock-path packages/coding-agent/package-lock.json

# Update all locked hashes and versions (recomputes npmDepsHash for npm-tracked deps)
mdep update

# Update without recomputing npm deps hashes
mdep update --no-npm-deps
```

**Important**: Use explicit `type` values. Let `mdep` manage `rev`, `tag`, `version`, `url`, `hash`, and `npmDepsHash` automatically—don't edit these fields manually.

---

## Complete Command Reference

| Command                                                                    | Purpose                                                                                           |
| -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `nix flake check --no-build --quiet`                                       | Validate flake structure without building. Catches evaluation errors quickly.                     |
| `nixos-rebuild build --flake .#<host>`                                     | Build NixOS configuration for `<host>` without applying. Verify before deploying.                 |
| `darwin-rebuild build --flake .#<host>`                                    | Build nix-darwin configuration for `<host>` without applying. Verify before deploying.            |
| `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`      | Build the NixOS toplevel (system closure) for `<host>`. Lower-level alternative to nixos-rebuild. |
| `nix eval .#darwinConfigurations`                                          | Inspect available darwin outputs without building. Useful for checking available hosts.           |
| `nix build .#darwinConfigurations.<host>.activationPackage`                | Build darwin activation package for `<host>` without applying it. Recommended for CI/testing.     |
| `home-manager build --flake .#<host>`                                      | Build Home Manager profile for `<host>`. Outputs activation script to `result/`.                  |
| `mdep add <name> <repo-url> -t <type> ...`                                 | Add dependency to `deps-lock.json` (git, github-release, pypi, npm).                              |
| `mdep add <name> <repo-url> -t github-release --npm-deps-lock-path <path>` | Add a github-release dep and auto-compute its `npmDepsHash` from the specified npm lockfile.      |
| `mdep update`                                                              | Refresh all locked versions, hashes, URLs, and npmDepsHash values in `deps-lock.json`.            |
| `mdep update --no-npm-deps`                                                | Refresh source hashes only; skip npmDepsHash recomputation.                                       |

---

## Common Issues and Debugging

**Flake check fails with "attribute not found"**  
→ Verify the host is registered in `hosts/default.nix` with the correct `kind` (nixos or darwin).

**Module receives unexpected special args**
→ Check `flake.nix` (line ~45-60) to see which special args are injected. Modules receive `isHm`, `isNixOs`, `isDarwin`, plus all flake inputs and `customPkgs`.

**customPkgs package not found**
→ Ensure the file is in `packages/` with a matching name (e.g., `packages/aws-local.nix` → `customPkgs.aws-local`).

**Overlay not applied**
→ Check `overlays/default.nix` auto-loads files from `overlays/`. Verify overlay file uses correct signature: `{ deps, depsLock, lib, ... }: final: prev: { ... }`.

---

## Maintenance Guardrails

**Documentation sync rule:**
When a change affects repository structure, setup/usage, conventions, or contributor workflow, update both `README.md` and `AGENTS.md` in the same commit so docs match the codebase.

**Rationale**: Stale documentation teaches AI assistants outdated patterns, causing integration failures and bugs.
