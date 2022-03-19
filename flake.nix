{
  inputs.nixpkgs-2105.url = "github:nixos/nixpkgs/nixos-21.05";
  inputs.nixpkgs-2111.url = "github:nixos/nixpkgs/nixos-21.11";
  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.master.url = "github:nixos/nixpkgs/master";

  inputs.nix.url = "github:nixos/nix"; #/caf51729450d4c57d48ddbef8e855e9bf65f8792";
  inputs.rnix-lsp.url = "github:nix-community/rnix-lsp/master";
  inputs.rnix-lsp.inputs.nixpkgs.follows = "unstable";
  # inputs.rnix-lsp.inputs.naersk.inputs.nixpkgs.follows = "unstable";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.emacs.url = "github:nix-community/emacs-overlay";
  inputs.emacs.inputs.nixpkgs.follows = "master";

  inputs.nixos-vscode-server.url = "github:mudrii/nixos-vscode-ssh-fix/main";

  inputs.statix.url = "github:nerdypepper/statix";
  inputs.alejandra.url = "github:kamadorueda/alejandra/1.1.0";

  outputs = {self, ...} @ inputs: {
    nixosModules = import ./nixos/modules inputs;
    nixosConfigurations = import ./nixos/configurations inputs;

    homeModules = import ./home/modules inputs;
    homeConfigurations = import ./home/configurations inputs;

    packages.x86_64-linux =
      (import ./packages inputs)
      // self.lib.nixosConfigurationsAsPackages.x86_64-linux
      // self.lib.homeConfigurationsAsPackages.x86_64-linux;

    checks = self.packages;

    lib = import ./lib inputs;

    apps.x86_64-linux = {
      update = import ./apps/update inputs;
      switch = import ./apps/switch inputs;
    };

    devShell.x86_64-linux = let
      pkgs = inputs.unstable.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        packages = [
          inputs.rnix-lsp.defaultPackage.x86_64-linux
          inputs.statix.defaultPackage.x86_64-linux
          inputs.alejandra.defaultPackage.x86_64-linux
        ];
      };
  };
}
