{
  self,
  nix,
  nixpkgs,
  programsdb,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}:
# if the assertion fails that means we had a branchoff/release
# We have to bump the version here and below for the stable branches
assert lib.hasPrefix "26.11" lib.version; let
  base = "/etc/nixpkgs/channels";
  nixpkgsPath = "${base}/nixpkgs";

  nixpkgsTarball = channel: {
    "from" = {
      "id" = "nixpkgs";
      "type" = "indirect";
      "ref" = channel;
    };
    "exact" = true;
    "to" = {
      "type" = "tarball";
      "url" = "https://channels.nixos.org/${channel}/nixexprs.tar.zst";
    };
  };

  registryContent = {
    flakes = [
      {
        from = {
          id = "self";
          type = "indirect";
        };
        exact = true;
        to = {
          type = "path";
          inherit (self) lastModified narHash;
          ${
            if self ? "rev"
            then "rev"
            else null
          } =
            self.rev or null;
          path = self;
        };
      }
      {
        from = {
          id = "nix";
          "type" = "indirect";
        };
        to = {
          owner = "nixos";
          repo = "nix";
          type = "github";
        };
      }
      {
        from = {
          id = "nvim";
          type = "indirect";
        };
        to = {
          owner = "nobbz";
          repo = "nobbz-vim";
          type = "github";
        };
      }
      {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        to = {
          type = "path";
          inherit (nixpkgs) lastModified narHash rev;
          path = nixpkgs;
        };
        exact = true;
      }
      (nixpkgsTarball "nixos-unstable")
      (nixpkgsTarball "nixos-unstable-small")
      (nixpkgsTarball "nixos-26.05")
      (nixpkgsTarball "nixos-26.05-small")
      {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        to = {
          owner = "NixOS";
          ref = "nixos-unstable";
          repo = "nixpkgs";
          type = "github";
        };
      }
    ];
    version = 2;
  };
in {
  options.nix.flakes.enable = lib.mkEnableOption "nix flakes";

  config = lib.mkIf config.nix.flakes.enable {
    programs.command-not-found.dbPath = lib.mkForce programsdb.packages.${pkgs.stdenv.hostPlatform.system}.programs-sqlite;

    nix = {
      package = lib.mkDefault nix.packages.${pkgs.stdenv.hostPlatform.system}.nix-cli;

      settings.experimental-features = ["nix-command" "flakes"];

      settings.flake-registry = pkgs.writeTextFile {
        name = "flake-registry.json";
        text = builtins.toJSON registryContent;
      };

      registry = lib.mkForce {};

      nixPath = [
        "nixpkgs=${nixpkgsPath}"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ ${nixpkgsPath}     - - - - ${nixpkgs}"
    ];
  };
}
