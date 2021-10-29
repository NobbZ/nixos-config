{ pkgs, lib, config, ... }:

let
  cfg = config.services.dns;

  namedConf = pkgs.writeText "named.conf" ''
    zone "nobbz.lan" IN {
      type master;
      file "${nobbzLanZone}";
    };
  '';

  nobbzLanZone = pkgs.writeText "nobbz.lan.zone" ''
    ; BIND db file for nobbz.lan

    $TTL 3600

    @       IN      SOA     dns.nobbz.lan. nmelzer.nobbz.dev (
                            2021102801  ; serial number YYMMDDNN
                            28800       ; Refresh
                            7200        ; Retry
                            864000      ; Expire
                            86400       ; Min TTL
                            )

                    NS      dns.nobbz.lan

                    CNAME   mimas.nobbz.lan.

    $ORIGIN nobbz.lan.

    mimas       IN  A     172.24.152.168
    thetys      IN  A     172.24.231.199
    enceladeus  IN  A     172.24.199.101

    enceladeus  IN  AAAA  fcc5:ee64:a023:8429:3ae6:0000:0000:0001
    thetys      IN  AAAA  fcc5:ee64:a0a6:f7e0:0020:0000:0000:0001
    mimas       IN  AAAA  fcc5:ee64:a0cd:9c36:c3ff:0000:0000:0001

    dns         IN  CNAME mimas
  '';
in
{
  options.services.dns = {
    enable = lib.mkEnableOption "DNS Server";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev:
        {
          powerdns = prev.powerdns.overrideAttrs (oa: rec {
            version = "4.5.1";
            src = pkgs.fetchurl {
              url = "https://downloads.powerdns.com/releases/pdns-${version}.tar.bz2";
              sha256 = "sha256-dNY8eqBHTePCE3u4CBZGkaGjpilC0qmnC2SM0neSP5s=";
            };
            patches = [ ];
          });
        })
    ];

    services.powerdns = {
      enable = true;

      extraConfig = ''
        launch = bind
        bind-config = ${namedConf}
        local-address = 127.0.0.1:5353 [::1]:5353 172.24.152.168:5353
      '';
    };

    services.pdns-recursor = {
      enable = true;

      dns.address = "172.24.152.168";
      dns.allowFrom = [
        "10.0.0.0/8"
        "172.0.0.0/8"
        "192.168.0.0/16"
        "172.24.152.168/16"
      ];

      settings = {
        trace = "fail";
        webserver = true;
        dnssec = "off";
        forward-zones = [
          "nobbz.lan=172.24.152.168:5353"
          "fritz.box=192.168.179.1"
          "office.cloudseeds.de=185.41.104.226"
        ];
        forward-zones-recurse = [
          ".=1.1.1.1;185.41.104.226"
        ];
      };
    };
  };
}
