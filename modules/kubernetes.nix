{ config, ... }:

let
  hostname = config.networking.hostName;

  # This IP is in the zerotier network, making the kubernetes network
  # available within the network only so far.
  ip = "192.168.178.76"; # TODO: make an option to configure.
in {
  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = hostname;
    kubelet.extraOpts = "--fail-swap-on=false";
    easyCerts = true;

    apiserver = {
      enable = true;
      insecurePort = 80;
      securePort = 8443;
      advertiseAddress = ip;
    };

    addonManager.enable = true;
    addons = {
      dashboard.enable = true;
    };
  };
}
