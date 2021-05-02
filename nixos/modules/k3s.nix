{ config, lib, pkgs, unstable, ... }:

{
  services.k3s = {
    enable = true;
    package = unstable.legacyPackages.x86_64-linux.k3s;
    role = "server";
    docker = true;
    extraFlags = "--write-kubeconfig-mode 644 --disable traefik --default-local-storage-path /opt/local-path-provisioner";
  };

  systemd.services.k3s.path = [ pkgs.zfs ];

  # https://github.com/NixOS/nixpkgs/issues/103158
  systemd.services.k3s.after = [ "network-online.service" "firewall.service" ];
  systemd.services.k3s.serviceConfig.KillMode = lib.mkForce "control-group";

  # https://github.com/NixOS/nixpkgs/issues/98766
  boot.kernelModules = [ "br_netfilter" "ip_conntrack" "ip_vs" "ip_vs_rr" "ip_vs_wrr" "ip_vs_sh" "overlay" ];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i cni+ -j ACCEPT
  '';
}
