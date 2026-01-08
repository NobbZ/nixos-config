{
  config,
  lib,
  ...
}: {
  services.prometheus = {
    enable = true;
    port = 9001;

    rules = [
      ''
        groups:
        - name: test
          rules:
          - record: nobbz:code_cpu_percent
            expr: avg without (cpu) (irate(node_cpu_seconds_total[5m]))
      ''
    ];

    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        port = 9002;
      };
    };

    scrapeConfigs = [
      {
        job_name = "grafana";
        static_configs = [{targets = ["127.0.0.1:2342"];}];
      }
      {
        job_name = "prometheus";
        static_configs = [{targets = ["127.0.0.1:9001"];}];
      }
      {
        job_name = "node_import";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              "${config.lib.nobbz.enceladeus.v4}:9002"
            ];
          }
        ];
      }
    ];
  };

  services.traefik.dynamicConfigOptions.http.routers.prometheus = {
    entryPoints = ["https" "http"];
    rule = "Host(`prometheus.mimas.internal.nobbz.dev`)";
    service = "prometheus";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.prometheus.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://127.0.0.1:${toString config.services.prometheus.port}";}];
  };
}
