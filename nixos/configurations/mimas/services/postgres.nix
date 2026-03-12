{pkgs, ...}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    extensions = ps: [ps.postgis];
  };

  systemd.targets.postgresql.unitConfig.RequiresMountsFor = ["/var/lib/postgresql"];
}
