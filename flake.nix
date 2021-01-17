{
  inputs = {
    # Main channels
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-20.09";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    cryptomator.url = "github:nixos/nixpkgs/2eb8804497a506d8c1a0363f99a08ad1d688a24f";

    cloud-native = {
      url = "github:shanesveller/flake-cloud-native";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Overlays
    emacs.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, emacs, ... }@inputs:
    let
      pkgs = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        overlays = builtins.attrValues self.overlays;
      };

      pkgs-stable = import inputs.nixpkgs-stable {
        system = "x86_64-linux";
        overlays = builtins.attrValues self.overlays;
      };
    in
    {
      overlay = import ./nix/myOverlay;

      overlays = {
        inputs = final: prev: { inherit inputs; };
        emacs = emacs.overlay;
        self = self.overlay;
      };

      lib = import ./lib inputs;

      homeConfigurations = {
        tux-nixos = self.lib.mkHomeConfig "nmelzer" ./hosts/tux-nixos.nix;
        delly-nixos = self.lib.mkHomeConfig "nmelzer" ./hosts/delly-nixos.nix;
        nixos = self.lib.mkHomeConfig "demo" ./hosts/nixos.nix;
        WS0005 = self.lib.mkHomeConfig "nmelzer" ./hosts/WS0005.nix;
      };

      apps.x86_64-linux = {
        build = { type = "app"; program = "${self.packages.x86_64-linux.build-config}"; };
        switch = { type = "app"; program = "${self.packages.x86_64-linux.switch-config}"; };
      };

      defaultApp.x86_64-linux = self.apps.x86_64-linux.switch;

      packages.x86_64-linux = {
        advcp = pkgs.callPackage ./packages/advcp { };
        elixir-lsp = pkgs.beam.packages.erlang.callPackage ./packages/elixir-lsp {
          rebar3 = pkgs-stable.beam.packages.erlang.rebar3;
        };
        erlang-ls = pkgs.beam.packages.erlang.callPackage ./packages/erlang-ls { };
        keyleds = pkgs.callPackage ./packages/keyleds {
          stdenv = pkgs.gcc8Stdenv;
        };
        rofi-unicode = pkgs.callPackage ./packages/rofi-unicode { };
        nix-zsh-completions = pkgs.nix-zsh-completions;
        keepass = pkgs.keepass;
        julia_10 = pkgs.julia_10;
        julia_13 = pkgs.julia_13;
        julia_15 = pkgs.julia_15;
        emacsGit = pkgs.emacsGit;
        cryptomator = inputs.cryptomator.legacyPackages.x86_64-linux.cryptomator;

        flux2 = inputs.cloud-native.packages.x86_64-linux.flux2;

        update-config = pkgs.callPackage ./scripts/update-config { };

        build-config = pkgs.writeShellScript "build-config.sh" ''
          set -ex

          if [ -z $1 ]; then
            name=$(${pkgs.nettools}/bin/hostname)
          else
            name=$1
          fi

          nix build -L --out-link "result-$name" ".#$name"
        '';

        switch-config = pkgs.writeShellScript "switch-config.sh" ''
          set -ex

          name=$(${pkgs.nettools}/bin/hostname)
          outLink=$(mktemp -d)/result-$name

          nix build -L --out-link "$outLink" ".#$name"
          $outLink/activate
          rm $outLink
        '';
      } // builtins.mapAttrs
        (_: config:
          config.activationPackage)
        self.homeConfigurations;

      devShell.x86_64-linux = pkgs.mkShell {
        name = "home-manager-shell";

        buildInputs = with pkgs; [ git lefthook nixpkgs-fmt ];
      };
    };
}
