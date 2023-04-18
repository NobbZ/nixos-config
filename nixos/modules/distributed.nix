_: {
  config,
  lib,
  ...
}: let
  machines = {
    # Please try to keep the definitions alphabetically sorted
    enceladeus = {
      systems = ["i686-linux" "x86_64-linux"];
      supportedFeatures = [];
      sshUser = "root";
      sshKey = "/home/nmelzer/.ssh/id_rsa"; # TODO: sopsify
      speedFactor = 1;
      protocol = "ssh-ng";
      maxJobs = 2;
      hostName = "enceladeus";
    };

    mimas = {
      systems = ["i686-linux" "aarch64-linux" "x86_64-linux"];
      supportedFeatures = ["kvm" "big-parallel"];
      sshUser = "root";
      sshKey = "/home/nmelzer/.ssh/id_rsa"; # TODO: sopsify
      speedFactor = 8;
      protocol = "ssh-ng";
      maxJobs = 4;
      hostName = "mimas";
    };
  };

  names = builtins.attrNames machines;

  inherit (lib.types) listOf enum;
  inherit (config.nix) enabledMachines distributedBuilds;
  inherit (config.networking) hostName;

  selfRemote = builtins.elem hostName enabledMachines;
in {
  _file = ./distributed.nix;

  options.nix = {
    enabledMachines = lib.mkOption {
      type = listOf (enum names);
      default = [];
      description = ''
        A list of hosts to use for remote builds.
      '';
    };
  };

  config = lib.mkIf distributedBuilds {
    assertions = [
      {
        assertion = !selfRemote;
        message = "You are not allowed to use yourself as a distributed builder";
      }
    ];
    nix.buildMachines = builtins.map (name: builtins.getAttr name machines) enabledMachines;
  };
}
