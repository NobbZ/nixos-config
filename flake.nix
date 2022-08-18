{
  inputs.nixpkgs-2105.url = "github:nixos/nixpkgs/nixos-21.05";
  inputs.nixpkgs-2111.url = "github:nixos/nixpkgs/nixos-21.11";
  inputs.nixpkgs-2205.url = "github:nixos/nixpkgs/nixos-22.05";
  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.master.url = "github:nixos/nixpkgs/master";

  inputs.nix.url = "github:nixos/nix"; #/caf51729450d4c57d48ddbef8e855e9bf65f8792";
  # inputs.rnix-lsp.url = "github:nix-community/rnix-lsp/master";
  # inputs.rnix-lsp.inputs.nixpkgs.follows = "nixpkgs-2111";
  # inputs.rnix-lsp.inputs.naersk.inputs.nixpkgs.follows = "unstable";

  inputs.nil.url = "github:oxalica/nil";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.emacs.url = "github:nix-community/emacs-overlay";
  inputs.emacs.inputs.nixpkgs.follows = "master";

  inputs.nixos-vscode-server.url = "github:mudrii/nixos-vscode-ssh-fix/main";

  inputs.statix.url = "github:nerdypepper/statix";
  inputs.alejandra.url = "github:kamadorueda/alejandra/1.4.0";

  outputs = {self, ...} @ inputs: {
    nixosModules = import ./nixos/modules inputs;
    nixosConfigurations = import ./nixos/configurations inputs;

    homeModules = import ./home/modules inputs;
    homeConfigurations = import ./home/configurations inputs;

    mixedModules = import ./mixed inputs;

    packages.x86_64-linux =
      (import ./packages inputs)
      // self.lib.nixosConfigurationsAsPackages.x86_64-linux
      // self.lib.homeConfigurationsAsPackages.x86_64-linux;

    checks.x86_64-linux = import ./checks inputs;

    lib = import ./lib inputs;

    devShell.x86_64-linux = self.devShells.x86_64-linux.default;
    devShells.x86_64-linux.default = inputs.unstable.legacyPackages.x86_64-linux.mkShell {
      packages = __attrValues {
        inherit (self.packages.x86_64-linux) nil alejandra;
        inherit (inputs.unstable.legacyPackages.x86_64-linux) rust-analyzer rustc cargo rustfmt clippy openssl pkg-config;
      };
    };
  };
}
