{
  inputs.nixpkgs-2009.url = "github:nixos/nixpkgs/nixos-20.09";
  inputs.nixpkgs-2105.url = "github:nixos/nixpkgs/nixos-21.05";
  inputs.nixpkgs-2111.url = "github:nixos/nixpkgs/nixos-21.11";
  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.master.url = "github:nixos/nixpkgs/master";

  inputs.nix.url = "github:nixos/nix/master";
  inputs.rnix-lsp.url = "github:nix-community/rnix-lsp/master";
  inputs.rnix-lsp.inputs.nixpkgs.follows = "unstable";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.emacs.url = "github:nix-community/emacs-overlay";
  inputs.emacs.inputs.nixpkgs.follows = "master";

  outputs = { self, ... }@inputs:
    {
      nixosModules = import ./nixos/modules;
      nixosConfigurations = import ./nixos/configurations inputs;

      homeModules = import ./home/modules;
      homeConfigurations = import ./home/configurations inputs;

      packages.x86_64-linux = (import ./packages inputs)
        // self.lib.nixosConfigurationsAsPackages.x86_64-linux
        // self.lib.homeConfigurationsAsPackages.x86_64-linux;

      checks = self.packages;

      lib = import ./lib inputs;

      apps.x86_64-linux = {
        update = import ./apps/update inputs;
        switch = import ./apps/switch inputs;
      };
    };
}
