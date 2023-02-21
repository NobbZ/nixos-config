{
  inputs.nixpkgs-2105.url = "github:nixos/nixpkgs/nixos-21.05";
  inputs.nixpkgs-2111.url = "github:nixos/nixpkgs/nixos-21.11";
  inputs.nixpkgs-2205.url = "github:nixos/nixpkgs/nixos-22.05";
  inputs.nixpkgs-2211.url = "github:nixos/nixpkgs/nixos-22.11";
  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.master.url = "github:nixos/nixpkgs/master";
  inputs.nixpkgs-insync.url = "github:nixos/nixpkgs/bd751508cf67db3b13b03e25eb937854fc92ee30";

  inputs.parts.url = "github:hercules-ci/flake-parts";

  inputs.programsdb.url = "github:wamserma/flake-programs-sqlite";
  inputs.programsdb.inputs.nixpkgs.follows = "unstable";

  # The following is required to make flake-parts work.
  inputs.nixpkgs.follows = "unstable";

  inputs.nix.url = "github:nixos/nix";

  inputs.nil.url = "github:oxalica/nil";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.emacs.url = "github:nix-community/emacs-overlay";
  inputs.emacs.inputs.nixpkgs.follows = "master";

  inputs.nixos-vscode-server.url = "github:msteen/nixos-vscode-server";

  inputs.statix.url = "github:nerdypepper/statix";
  inputs.alejandra.url = "github:kamadorueda/alejandra/3.0.0";

  outputs = {
    self,
    parts,
    ...
  } @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      imports = [
        ./parts/auxiliary.nix
        ./parts/home_configs.nix
        ./parts/system_configs.nix

        ./nixos/configurations
        ./home/configurations
      ];

      flake = {
        nixosModules = import ./nixos/modules inputs;

        homeModules = import ./home/modules inputs;

        mixedModules = import ./mixed inputs;

        packages.x86_64-linux = import ./packages inputs "x86_64-linux";
        packages.aarch64-linux = import ./packages inputs "aarch64-linux";
        packages.aarch64-darwin = import ./packages inputs "aarch64-darwin";

        checks.x86_64-linux = import ./checks inputs;
      };
    };
}
