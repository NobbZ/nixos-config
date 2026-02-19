{
  outputs = {parts, ...} @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      debug = true;

      _module.args.npins = import ./npins;

      imports = [
        ./parts/auxiliary.nix
        ./parts/home_configs.nix
        ./parts/home_modules.nix
        ./parts/nixos_modules.nix
        ./parts/system_configs.nix

        ./nixos/configurations
        ./home/configurations

        ./home/modules
        ./nixos/modules

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
              -m 8G \
              -smp 2 \
              -enable-kvm \
              -netdev user,id=net0 \
              -device virtio-net,netdev=net0 \
              -device virtio-vga \
              -bios ${pkgs.OVMF.fd}/FV/OVMF.fd

            du -h $isoFull
            rm -f $isoPath
          '';

        apps.awesome-preview.program = let
          rc_lua = pkgs.runCommand "awesomerc.lua" {} ''
            substitute ${./packages/installer/awesomerc.lua} $out \
              --subst-var-by FILE_PATH_WALLPAPER ${./packages/installer/nix-glow-black.png} \
              --subst-var-by NIX_FLAKE_SVG       ${./packages/installer/nix-flake.svg}
          '';
        in
          pkgs.writeShellScriptBin "awesome-preview" ''
            ${pkgs.xorg-server}/bin/Xephyr :5 & sleep 1 ; DISPLAY=:5 ${self'.packages.awesome}/bin/awesome --config ${rc_lua}
          '';
      };

      flake = {
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
    nvim.inputs.nixpkgs.follows = "nixpkgs";

    switcher.url = "github:nobbz/nix-switcher?ref=main";
    # switcher.inputs.nixpkgs.follows = "nixpkgs";
    switcher.inputs.flake-parts.follows = "parts";

    parts.url = "github:hercules-ci/flake-parts";
    parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    programsdb.url = "github:wamserma/flake-programs-sqlite";
    programsdb.inputs.nixpkgs.follows = "nixpkgs";

    nix.url = "github:nixos/nix";
    nix.inputs.flake-parts.follows = "parts";
    # a libgit2 in the current version fails to build with the nix provided patches.
    # therefore using upstreams pin for now.
    # nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-gl.url = "github:nix-community/nixgl";
    nix-gl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    emacs.inputs.nixpkgs-stable.follows = "nixpkgs";

    nixos-vscode-server.url = "github:msteen/nixos-vscode-server";
    nixos-vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
  };
}
