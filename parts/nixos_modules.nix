{
  self,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.nobbz.nixosModules;

  inherit (builtins) isString isPath;

  callModule = module: args: let
    moduleToImport =
      if args == null
      then module
      else import module args;
  in
    {imports = [moduleToImport];}
    // lib.optionalAttrs (builtins.any (p: p module) [isPath isString]) {_file = module;};

  modules = builtins.mapAttrs (_: config: config.wrappedModule) cfg;
in {
  options = {
    nobbz.nixosModules = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = name;
          };

          module = lib.mkOption {
            type = lib.types.oneOf [
              lib.types.str
              lib.types.path
              # TODO: add sets and functions
            ];
          };

          extraArgs = lib.mkOption {
            type = lib.types.nullOr (lib.types.attrsOf lib.types.unspecified);
            default = inputs;
          };

          wrappedModule = lib.mkOption {
            type = lib.types.unspecified;
            readOnly = true;
          };
        };

        config = {
          wrappedModule = callModule config.module config.extraArgs;
        };
      }));
    };
  };

  config.flake.nixosModules = modules;
}
