{
  pkgs,
  config,
  lib,
  ...
}: {
  _file = ./motd.nix;

  users.motd = "This is a test message.";

  systemd.user.services.motd = {
    description = "Prints a test message";
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.zenity} --info --text='${config.users.motd}'";
      Restart = "on-failure";
    };
  };
}
