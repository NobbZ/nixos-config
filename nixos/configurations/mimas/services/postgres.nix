{pkgs, ...}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
  };

  systemd.targets.postgresql.unitConfig.RequiresMountsFor = ["/var/lib/postgresql"];
}
