{
  inputs.nixpkgs-2009.url = "github:nixos/nixpkgs/nixos-20.09";
  inputs.nixpkgs-2105.url = "github:nixos/nixpkgs/nixos-21.05";
  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.master.url = "github:nixos/nixpkgs/master";

  inputs.nix.url = "github:nixos/nix/master";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.emacs.url = "github:nix-community/emacs-overlay";
  inputs.emacs.inputs.nixpkgs.follows = "master";

  outputs = { self, ... }@inputs:
    {
      nixosModules = { };
      nixosConfigurations = { };

      homeModules = { };
      homeConfigurations = { };

      lib = { };

      checks = { };

      apps = { };
    };
}
