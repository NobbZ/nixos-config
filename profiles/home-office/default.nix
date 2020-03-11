{ config, lib, pkgs, ... }:

let cfg = config.profiles.home-office;

in {
  options.profiles.home-office = {
    enable = lib.mkEnableOption
      "A profile that enables remote desktop to the workingplace";

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.string;
      default = null;
      example = "jon.doe";
      description = ''
        The username used to login to the RDP host
      '';
    };

    pass = lib.mkOption {
      type = lib.types.nullOr lib.types.string;
      default = null;
      example = "secret";
      description = ''
        The password used to login to the RDP host
      '';
    };

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.string;
      default = null;
      example = "secret";
      description = ''
        The domain used to login to the RDP host
      '';
    };

    host = lib.mkOption {
      type = lib.types.nullOr lib.types.string;
      default = null;
      example = "example.com";
      description = ''
        The hostname or IP of the RDP host
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: add assertions for `user`, `pass`, and `host` beeing set.

    home.packages = [
      (pkgs.writeShellScriptBin "home-office" ''
        ${pkgs.freerdp}/bin/xfreerdp '/u:${cfg.user}' '/p:${cfg.pass}' '/d:${cfg.domain}' '/v:${cfg.host}' /dynamic-resolution
      '')
    ];
  };
}
