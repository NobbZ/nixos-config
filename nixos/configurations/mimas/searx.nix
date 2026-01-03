_inputs: {
  config,
  pkgs,
  ...
}: {
  sops.secrets.searx = {};

  services.searx = {
    enable = true;

    package = pkgs.searxng;

    domain = "search.mimas.internal.nobbz.dev";

    environmentFile = config.sops.secrets.searx.path;

    settings = {
      search = {
        autocomplete = "google";
        favicon_resolver = "google";
        default_lang = "auto";
      };

      server.port = 8888;

      engines = [
        {
          name = "hex";
          categories = ["code" "elixir" "it"];
        }
        {
          name = "elixirforum";
          engine = "discourse";
          shortcut = "exf";
          base_url = "https://elixirforum.com/";
          show_avatar = true;
          categories = ["code" "it" "software forums" "elixir"];
        }
        {
          name = "nixos discourse";
          engine = "discourse";
          shortcut = "nixd";
          base_url = "https://discourse.nixos.org/";
          show_avatar = true;
          categories = ["it" "software forums" "nix"];
        }
        {
          name = "nixos wiki";
          categories = ["it" "software wikis" "nix"];
        }
      ];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.searx = {
      entrypoints = ["http" "https"];
      rule = "Host(`${config.services.searx.domain}`)";
      service = "searx";
      tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
      tls.certResolver = "mimasWildcard";
    };

    services.searx = {
      loadBalancer.passHostHeader = true;
      loadBalancer.servers = [{url = "http://localhost:${toString config.services.searx.settings.server.port}";}];
    };
  };
}
