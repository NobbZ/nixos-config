# Copilot Instructions for nixos-config

## Repository Overview

This is a **personal NixOS configuration repository** managing system and home-manager configurations for multiple hosts using Nix Flakes. The repository is ~12MB with 72 Nix files and uses a modular flake-parts architecture.

**⚠️ CRITICAL**: This repository contains hardware-specific configurations. Do NOT suggest building or deploying these configurations to other systems as they can render machines unbootable.

**Languages/Frameworks**: Nix (primary), CUE (workflow generation), Lua (AwesomeWM config), Shell scripts
**Target Systems**: x86_64-linux, aarch64-linux, aarch64-darwin
**Nix Version**: 2.32.1 (as specified in CI workflows)

## Build and Validation Commands

### Prerequisites
- Nix with flakes enabled must be installed
- CUE v0.14.2 required for workflow generation
- Tools available in dev shell: `nix develop` provides npins, sops, age, ssh-to-age, nil, alejandra, lua-language-server, cue

### Core Commands (Tested & Working)

**Formatting (ALWAYS run before committing)**:
```bash
nix fmt                    # Format all Nix files using alejandra
make fmt                   # Format both CUE and Nix files
```

**Linting**:
```bash
nix run --inputs-from . nixpkgs#statix -- check    # Lint Nix files
statix check -i packages/nodePackages/node-env.nix  # Alternative, ignores generated files
```
Note: `statix.toml` configures ignored paths and disabled checks. The `repeated_keys` check is disabled.

**Building Flake Outputs**:
```bash
nix flake check --keep-going    # Check all flake outputs (may take 10+ minutes)
nix flake show                  # Display all flake outputs
nix flake show --json           # JSON output for parsing
```

**Building Specific Outputs**:
```bash
nix build .#checks.x86_64-linux.<check-name> --no-link
nix build .#packages.x86_64-linux.<package-name>
nix build .#nixosConfigurations.mimas.config.system.build.toplevel
```

**Workflow Generation** (when modifying `cicd/*.cue`):
```bash
make workflows              # Generate all workflows from CUE definitions
make check                  # Validate CUE matches generated YAML files
```
**IMPORTANT**: If you modify `cicd/*.cue` files, ALWAYS run `make workflows` to regenerate the YAML files before committing.

### Git Pre-commit Hooks
The repository uses `lefthook` for pre-commit checks:
- **Formatting check**: Runs `nix fmt -- --check` on staged `.nix` files
- **Linting**: Runs `statix check` on `.nix` files

To manually trigger these: Run the commands above before committing.

## CI/CD Pipeline

### Pull Request Checks (`.github/workflows/pull-check.yml`)
1. **generate_matrix**: Discovers all packages and checks from flake
2. **build_flake**: Builds all packages (except installer-iso) in parallel (max 5 concurrent)
3. **build_checks**: Builds all checks in parallel
4. **check_flake**: Runs `nix flake check --keep-going` (continue-on-error)

**Build Time**: Full CI can take 30-60+ minutes depending on cache hits. Uses cachix (nobbz cache) and nix-community cache.

### Generated Files Check (`.github/workflows/check-generated.yml`)
- Runs `make check` to verify CUE definitions match generated YAML files
- **CRITICAL**: This will FAIL if you modify `cicd/*.cue` without running `make workflows`

### Common CI Failure Patterns
1. **Formatting failures**: Run `nix fmt` before committing
2. **Statix failures**: Fix linting issues or add ignore patterns in `statix.toml`
3. **Generated files mismatch**: Run `make workflows` after modifying CUE files
4. **Build failures**: Test with `nix flake check` locally first
5. **Disk space issues**: Large builds use `wimpysworld/nothing-but-nix@main` action to free space

## Project Structure

### Root Directory Files
```
flake.nix           # Main flake entry point, imports all parts
flake.lock          # Locked dependencies (updated by bot)
Makefile            # CUE workflow generation and validation
lefthook.yml        # Pre-commit hook configuration
statix.toml         # Nix linter configuration
.envrc              # direnv configuration for dev shell
.sops.yaml          # Secret management with age keys
```

### Directory Layout
```
parts/              # Flake-parts modular configuration
├── auxiliary.nix           # Formatter, apps, devShell
├── system_configs.nix      # NixOS configuration generator (119 lines)
├── home_configs.nix        # Home-manager configuration generator (128 lines)
├── nixos_modules.nix       # NixOS module loader
├── home_modules.nix        # Home-manager module loader
└── module_helpers.nix      # Shared helpers for module loading

nixos/
├── configurations/         # Host-specific configurations
│   ├── default.nix        # Defines available hosts
│   ├── mimas.nix          # Primary host configuration
│   ├── hardware/*.nix     # Hardware-specific configs per host
│   └── bootloader/*.nix   # Bootloader configs per host
└── modules/               # Reusable NixOS modules
    ├── default.nix        # Module index
    ├── nix.nix           # Nix daemon configuration
    ├── switcher.nix      # NixOS rebuild wrapper
    ├── cachix/           # Binary cache configuration
    └── ...

home/
├── configurations/         # User@host home-manager configs
│   ├── default.nix        # Defines nmelzer@mimas, nmelzer@phoebe
│   ├── nmelzer_at_mimas.nix
│   └── nmelzer_at_phoebe.nix
└── modules/               # Reusable home-manager modules
    ├── default.nix        # Module index
    ├── profiles/          # Complete profile bundles
    │   ├── base/         # Base profile with shell, git, etc.
    │   ├── development/  # Development tools
    │   └── browsing/     # Browser configurations
    ├── programs/          # Individual program configs
    └── services/          # User services

packages/           # Custom packages
├── default.nix             # Package definitions
├── installer/              # Custom NixOS installer ISO
├── advcp/                  # Advanced cp/mv with progress
└── rofi-unicode/           # Rofi unicode selector

checks/             # Nix check definitions
├── default.nix             # Check loader
├── alejandra.nix           # Formatting check
└── statix.nix              # Linting check

cicd/               # CUE workflow definitions (source of truth)
├── workflows.cue           # Shared workflow components
├── pull-check.cue          # PR check workflow
├── flake-update.cue        # Auto-update workflow
├── check-generated.cue     # Generated file check
└── coderabbit.cue          # CodeRabbit config

.github/workflows/  # Generated YAML (DO NOT EDIT DIRECTLY)
├── pull-check.yml          # Generated from cicd/pull-check.cue
├── flake-update.yml        # Generated from cicd/flake-update.cue
└── check-generated.yml     # Generated from cicd/check-generated.cue

secrets/            # SOPS-encrypted secrets (age)
├── mimas/                  # Host-specific secrets
├── phoebe/                 # Host-specific secrets
└── users/                  # User-specific secrets

mixed/              # Modules used by both NixOS and home-manager
npins/              # Pinned dependencies (sources.json)
```

### Key Architecture Patterns

1. **Flake-parts Structure**: Uses `flake-parts` for modular flake organization. Each `parts/*.nix` file extends the flake schema.

2. **Configuration Generators**: `system_configs.nix` and `home_configs.nix` define options under `nobbz.nixosConfigurations.*` and `nobbz.homeConfigurations.*` which automatically generate flake outputs.

3. **Module Loading**: Modules in `nixos/modules/default.nix` and `home/modules/default.nix` are automatically loaded via `parts/*_modules.nix`.

4. **Naming Convention**: Home configurations use `username_at_hostname` format (e.g., `nmelzer_at_mimas.nix`).

5. **CUE-Generated Workflows**: GitHub Actions workflows are generated from CUE definitions. NEVER edit `.github/workflows/*.yml` directly—always edit `cicd/*.cue` and run `make workflows`.

6. **Secret Management**: Uses sops-nix with age encryption. Keys defined in `.sops.yaml`, secrets stored in `secrets/` hierarchy.

7. **Dependency Pinning**: Uses both flake lock and npins for dependency management. Npins is primarily for non-flake sources.

## Common Tasks

### Adding a New Package
1. Add package definition to `packages/default.nix` or create new directory under `packages/`
2. Export in the `packages` attribute set
3. Test: `nix build .#<package-name>`
4. Format: `nix fmt`

### Adding a NixOS Module
1. Create module file in `nixos/modules/`
2. Add entry to `nixos/modules/default.nix`
3. Module automatically available in all NixOS configurations

### Adding a Home-Manager Module
1. Create module file in `home/modules/{programs,services,misc}/`
2. Add entry to `home/modules/default.nix`
3. Module automatically available in all home configurations

### Modifying CI Workflows
1. Edit CUE definitions in `cicd/*.cue`
2. Run `make workflows` to regenerate YAML files
3. Run `make check` to verify
4. Commit both CUE and generated YAML files

### Working with Secrets
1. Ensure age keys are configured in `.sops.yaml`
2. Edit secrets: `sops secrets/<path>/default.yaml`
3. Keys automatically decrypted at activation via sops-nix

## Important Notes

- **Dev Shell**: Run `nix develop` for all tools (alejandra, statix, cue, sops, etc.)
- **Build Time**: Full flake check can take 30+ minutes. Test individual outputs first.
- **Cachix**: CI uses nobbz and nix-community caches. Local builds benefit from `cachix use nobbz`.
- **Ignored Files**: `npins/default.nix` and `packages/nodePackages/node-env.nix` are generated—don't lint or modify.
- **File Exclusions**: `/result*` directories are gitignored (nix build outputs).

## Validation Checklist Before PR

1. ✓ Run `nix fmt` to format all Nix files
2. ✓ Run `statix check` to lint Nix files
3. ✓ If modified `cicd/*.cue`: Run `make workflows && make check`
4. ✓ Test specific changes: `nix build .#<affected-output>`
5. ✓ For major changes: Run `nix flake check --keep-going` (allow 30+ min)
6. ✓ Ensure no secrets or credentials are committed
7. ✓ Check that only intended files are staged (no `result` dirs, etc.)

**Trust these instructions**: They are comprehensive and tested. Only search for additional information if you encounter errors not covered here or need specifics about module implementation details.
