{config, ...}: let
  inherit (config.services.glance) settings;
  inherit (settings.server) port host;
in {
  services.glance = {
    enable = true;

    settings = {
      server.port = 9000;

      theme = {
        background-color = "240 21 15";
        contrast-multiplier = 1.2;
        primary-color = "217 92 83";
        positive-color = "115 54 76";
        negative-color = "347 70 65";

        presets = {
          default-light = {
            light = true;
            background-color = "220 23 95";
            contrast-multiplier = 1.0;
            primary-color = "220 91 54";
            positive-color = "109 58 40";
            negative-color = "347 87 44";
          };
        };
      };

      pages = [
        {
          name = "Dashboard";
          slug = "dashboard";
          width = "default";
          desktop-navigation-width = "wide";
          center-vertically = true;
          hide-desktop-navigation = false;
          show-mobile-header = true;
          head-widgets = [
            {
              type = "search";
              search-engine = "https://search.mimas.internal.nobbz.dev/search?q={QUERY}";
            }
          ];
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "videos";
                  channels = [
                    # Gaming with Doc
                    "UCswAGtfmFDyVs7OB8qOxDRg"
                    # MrJakob
                    "UC-2w7N7aCqs_QclGUtXkSqg"
                    # NobbZdev
                    "UCqrWgtcXVGfaXDoMcuTlFaw"
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "monitor";
                  # style = "compact";
                  title = "Services";
                  sites = [
                    {
                      title = "Blog";
                      url = "https://blog.nobbz.dev";
                      icon = "mdi:newspaper";
                    }
                    {
                      title = "Vaultwarden";
                      url = "https://passwords.mimas.internal.nobbz.dev";
                      icon = "si:vaultwarden";
                    }
                    {
                      title = "Gitea";
                      url = "https://gitea.mimas.internal.nobbz.dev";
                      icon = "si:gitea";
                    }
                    {
                      title = "Restic";
                      url = "https://restic.mimas.internal.nobbz.dev";
                      icon = "mdi:cloud-upload";
                    }
                    {
                      title = "SearxNG";
                      url = "https://search.mimas.internal.nobbz.dev";
                      icon = "si:searxng";
                    }
                    {
                      title = "Paperless";
                      url = "https://paperless.mimas.internal.nobbz.dev";
                      icon = "si:paperlessngx";
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.glance = {
    entryPoints = ["http" "https"];
    rule = "Host(`dashboard.nobbz.dev`)";
    service = "glance";
    tls.domains = [{main = "dashboard.nobbz.dev";}];
    tls.certResolver = "dashboardNobbzDev";
  };

  services.traefik.dynamicConfigOptions.http.services.glance.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://${host}:${toString port}";}];
  };
}
