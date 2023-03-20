{
  inputs = {
    nixpkgs-2211.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    master.url = "github:nixos/nixpkgs/master";
    nixpkgs-insync-v3.url = "github:nixos/nixpkgs?ref=32fdc268e921994e3f38088486ddfe765d11df93";

    switcher.url = "github:nobbz/nix-switcher?ref=main";
    switcher.inputs.nixpkgs.follows = "unstable";
    switcher.inputs.flake-parts.follows = "parts";

    parts.url = "github:hercules-ci/flake-parts";

    programsdb.url = "github:wamserma/flake-programs-sqlite";
    programsdb.inputs.nixpkgs.follows = "unstable";

    # The following is required to make flake-parts work.
    nixpkgs.follows = "nixpkgs-unstable";
    unstable.follows = "nixpkgs-unstable";
    stable.follows = "nixpkgs-2211";

    # Known to work, try again after nixos/nix#8072 git fixed
    # https://github.com/NixOS/nix/issues/8072
    nix.url = "github:nixos/nix";

    nil.url = "github:oxalica/nil";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "unstable";

    flake-utils.url = "github:numtide/flake-utils";

    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "master";

    nixos-vscode-server.url = "github:msteen/nixos-vscode-server";

    sops-nix.url = "github:Mic92/sops-nix";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
  };

  outputs = {parts, ...} @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      imports = [
        ./parts/auxiliary.nix
        ./parts/home_configs.nix
        ./parts/system_configs.nix

        ./nixos/configurations
        ./home/configurations

        ./packages
      ];

      flake = {
        nixosModules = import ./nixos/modules inputs;

        homeModules = import ./home/modules inputs;

        mixedModules = import ./mixed inputs;

        checks.x86_64-linux = import ./checks inputs;
      };
    };
}
