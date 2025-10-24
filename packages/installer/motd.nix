{
  pkgs,
  lib,
  ...
}: {
  _file = ./motd.nix;

  users.motd = "This is a test message.";

  systemd.user.services.motd = {
    description = "Prints a test message";
    wantedBy = ["graphical-session.target"];
    script = ''
      motd=$(cat /etc/gui-motd)
      ${lib.getExe pkgs.zenity} --info --text="$motd" --no-wrap --title="Short usage notes"
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
    };
  };
}
