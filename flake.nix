{
  inputs = {
    nixpkgs-2211.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    master.url = "github:nixos/nixpkgs/master";
    nixpkgs-insync.url = "github:nixos/nixpkgs/bd751508cf67db3b13b03e25eb937854fc92ee30";

    parts.url = "github:hercules-ci/flake-parts";

    programsdb.url = "github:wamserma/flake-programs-sqlite";
    programsdb.inputs.nixpkgs.follows = "unstable";

    # The following is required to make flake-parts work.
    nixpkgs.follows = "nixpkgs-unstable";
    unstable.follows = "nixpkgs-unstable";
    stable.follows = "nixpkgs-2211";

    nix.url = "github:nixos/nix?ref=pull/7856/head";

    nil.url = "github:oxalica/nil";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "unstable";

    flake-utils.url = "github:numtide/flake-utils";

    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "master";

    nixos-vscode-server.url = "github:msteen/nixos-vscode-server";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
  };

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
