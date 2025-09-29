{pkgs, ...}: {
  networking.networkmanager.enable = true;

  systemd.user.services.nmapplet = {
    wantedBy = ["graphical-session.target"];
    script = "${pkgs.networkmanagerapplet}/bin/nm-applet";
  };
}
