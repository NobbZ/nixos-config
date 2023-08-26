{
  pkgs,
  lib,
  ...
}: {
  _file = ./motd.nix;

  environment.etc."gui-motd".text = ''
    Welcome to NobbZ' <b>inofficial</b> NixOS live disk!

    The tooling, configuration and drivers on this disk are mostly tailored to
    my own needs and might not work well for you.

    Currently you are looking at an <tt>awesome wm</tt> session, the modkey is
    <tt>Mod4</tt> (the "windows" key).

    Most important tooling is available through the "awesome" menu, which is
    located in the upper left corner of the screen.

    If you want to use the terminal, you can either use the menu, or press
    <tt>Mod4+Enter</tt>.

    <s>Rofi is available as well, you can open it by pressing <tt>Mod4+d</tt>.</s>

    A more complete list of keybindings can be found in the awesome help screen
    by pressing <tt>Mod4+s</tt>.
  '';

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
