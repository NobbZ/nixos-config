# AGENTS.md - NixOS Configuration Repository

This file contains essential information for agentic coding agents working with this personal NixOS configuration repository.

## Repository Overview

- **Primary Language**: Nix (flake-based configuration)
- **Supporting Languages**: CUE (workflow generation), Lua (AwesomeWM), Shell scripts
- **Architecture**: Modular flake-parts with NixOS and home-manager configurations
- **Target Systems**: x86_64-linux, aarch64-linux, aarch64-darwin
- **⚠️ CRITICAL**: Contains hardware-specific configs. NEVER build/deploy on other systems.

## Essential Commands

### Development Environment
```bash
nix develop                    # Enter dev shell with all tools
```

### Formatting (ALWAYS run before committing)
```bash
nix fmt .                      # Format all Nix files with alejandra
nix fmt . -- --check           # Check formatting without modifying files
make fmt                       # Format both CUE and Nix files
```

### Linting
```bash
statix check -i packages/nodePackages/node-env.nix  # Lint Nix files
nix build .#checks.x86_64-linux.statix --no-link   # Alternative via build
```

### Building and Testing
```bash
# Full flake validation (30+ minutes)
nix flake check --keep-going

# Build specific outputs
nix build .#packages.x86_64-linux.<package-name>
nix build .#checks.x86_64-linux.<check-name> --no-link
nix build .#nixosConfigurations.mimas.config.system.build.toplevel

# Show available outputs
nix flake show
nix flake show --json
```

### Single Test Execution
```bash
# Run a specific check
nix build .#checks.x86_64-linux.alejandra --no-link
nix build .#checks.x86_64-linux.statix --no-link

# Test specific package
nix build .#packages.x86_64-linux.advcp --no-link
```

### CUE Workflow Generation
```bash
make workflows                 # Regenerate all workflows from CUE
make check                     # Validate CUE matches generated YAML
```

## Code Style Guidelines

### Nix Formatting
- Use `alejandra` for all Nix files (automated via `nix fmt`)
- Maximum line length: 80 characters
- 2-space indentation (alejandra default)

### Module Structure
```nix
# Standard module pattern
{ config, lib, pkgs, ... }: {
  options = {
    # Module options here
  };

  config = {
    # Configuration here
  };
}
```

### Import and Attribute Conventions
```nix
# Input imports (first line)
{ config, lib, pkgs, ... }:

# Option definitions use lib.mkOption
options.myOption = lib.mkOption {
  type = lib.types.str;
  default = "default";
  description = "Description of the option";
};

# Conditional config
config = lib.mkIf condition {
  # Configuration
};
```

### Naming Conventions
- **Files**: kebab-case (e.g., `nix-config.nix`, `home-manager.nix`)
- **Options**: camelCase (e.g., `myCustomOption`)
- **Attributes**: kebab-case for flake outputs, camelCase for options
- **Home configs**: `username_at_hostname.nix` format

### Type Definitions
- Always specify types with `lib.mkOption`
- Use specific types (`lib.types.str`, `lib.types.listOf lib.types.str`)
- Provide descriptions for all options
- Use `lib.mkDefault` for sensible defaults

### Error Handling
- Use `lib.mkIf` for conditional configuration
- Validate inputs with proper types
- Use `lib.asserts.assertMsg` for runtime assertions when needed

### Import Organization
```nix
# 1. Standard inputs
{ config, lib, pkgs, inputs', ... }:

# 2. Local imports
let
  myHelper = import ../helpers.nix { inherit lib; };
in

# 3. Module body
{
  # Configuration
}
```

## File Organization Patterns

### Module Exports
Modules should be exported in `default.nix` files:
```nix
{
  nobbz.homeManagerModules = {
    "myProgram" = ./my-program;
    "myService" = ./my-service;
  };
}
```

### Package Definitions
```nix
{ pkgs, ... }:
{
  advcp = pkgs.callPackage ./advcp { };
  myPackage = pkgs.callPackage ./my-package { };
}
```

## CI/CD Integration

### Pre-commit Hooks (lefthook)
- **Formatting**: `nix fmt -- --check {staged_files}` on staged `.nix` files
- **Linting**: `statix check` on `.nix` files

### Generated Files
- **NEVER** edit `.github/workflows/*.yml` directly
- Always edit `cicd/*.cue` and run `make workflows`
- Run `make check` to verify CUE matches generated YAML

### Validation Checklist Before Commit
1. ✓ Run `nix fmt .` to format all Nix files
2. ✓ Run `statix check` to lint Nix files  
3. ✓ If modified `cicd/*.cue`: Run `make workflows && make check`
4. ✓ Test specific changes: `nix build .#<affected-output>`
5. ✓ Ensure no secrets or credentials are committed

## Project Structure

### Key Directories
- `parts/` - Flake-parts modular configuration
- `nixos/modules/` - Reusable NixOS modules
- `home/modules/` - Reusable home-manager modules
- `packages/` - Custom package definitions
- `cicd/` - CUE workflow definitions (source of truth)
- `checks/` - Nix check definitions

### Module Loading
- NixOS modules auto-loaded via `parts/nixos_modules.nix`
- Home modules auto-loaded via `parts/home_modules.nix`
- Add modules to respective `default.nix` files

## Important Notes

- **Ignore Files**: `npins/default.nix` and `packages/nodePackages/node-env.nix` are generated
- **Secret Management**: Uses sops-nix with age encryption
- **Caching**: Uses nobbz and nix-community cachix caches
- **Build Time**: Full flake check takes 30+ minutes, test individual outputs first

## Debugging

### Common Issues
- **Formatting failures**: Run `nix fmt .` before committing
- **Statix failures**: Fix linting or add to `statix.toml` ignore
- **Generated files mismatch**: Run `make workflows` after CUE changes
- **Build failures**: Test with `nix flake check --keep-going`

### Development Tools
All available in `nix develop`:
- `alejandra` - Nix formatter
- `statix` - Nix linter  
- `cue` - Workflow generator
- `sops` - Secret management
- `nil` - Nix language server