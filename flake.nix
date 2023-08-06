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

      _module.args.npins = import ./npins;

      imports = [
        ./parts/auxiliary.nix
        ./parts/home_configs.nix
        ./parts/system_configs.nix

        ./nixos/configurations
        ./home/configurations

        ./packages
      ];

      perSystem = {
        pkgs,
        self',
        ...
      }: {
        apps.installer.program = let
          isoPath = "iso/${self'.packages.installer-iso.isoName}";
        in
          pkgs.writeShellScriptBin "installer" ''
            image=disk.qcow2
            isoPath=$(mktemp -d)/result
            isoFull=$isoPath/${isoPath}

            test -f $image || ${pkgs.qemu}/bin/qemu-img create -f qcow2 $image 50G

            nom build .#installer-iso -o $isoPath

            ${pkgs.qemu}/bin/qemu-system-x86_64 \
              -drive file=$image,if=virtio \
              -cdrom $isoPath/${isoPath} \
              -m 8192 \
              -enable-kvm \
              -netdev user,id=net0 \
              -device virtio-net,netdev=net0 \
              -bios ${pkgs.OVMF.fd}/FV/OVMF.fd

            du -h $isoFull
            rm -f $isoPath
          '';
      };

      flake = {
        nixosModules = import ./nixos/modules inputs;

        homeModules = import ./home/modules inputs;

        mixedModules = import ./mixed inputs;

        checks.x86_64-linux = import ./checks inputs;
      };
    };
}
