{
  outputs = {parts, ...} @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      _module.args.npins = import ./npins;

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

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # nixpkgs-insync-v3.url = "github:nixos/nixpkgs?ref=32fdc268e921994e3f38088486ddfe765d11df93";
    nixpkgs-insync-v3.follows = "nixpkgs";
    nixpkgs-pre-rust.url = "github:nixos/nixpkgs?ref=57d0d4a8f302";

    nvim.url = "github:nobbz/nobbz-vim";
    nvim.inputs.parts.follows = "parts";

    switcher.url = "github:nobbz/nix-switcher?ref=main";
    switcher.inputs.nixpkgs.follows = "nixpkgs";
    switcher.inputs.flake-parts.follows = "parts";

    parts.url = "github:hercules-ci/flake-parts";
    parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    programsdb.url = "github:wamserma/flake-programs-sqlite";
    programsdb.inputs.nixpkgs.follows = "nixpkgs";

    nix.url = "github:nixos/nix";
    nix.inputs.flake-parts.follows = "parts";
    nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    emacs.inputs.nixpkgs-stable.follows = "nixpkgs";

    nixos-vscode-server.url = "github:msteen/nixos-vscode-server";
    nixos-vscode-server.inputs.flake-utils.follows = "emacs/flake-utils";
    nixos-vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
  };
}
