lib: inputs: let
  inherit (builtins) isString isPath;

  callModule = module: args: let
    moduleToImport =
      if args == null
      then module
      else import module args;
  in
    {imports = [moduleToImport];}
    // lib.optionalAttrs (builtins.any (p: p module) [isPath isString]) {_file = module;};

  from = lib.types.oneOf [lib.types.str lib.types.path];

  submodule = lib.types.coercedTo from (m: {module = m;}) (lib.types.submodule ({
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
in {
  inherit callModule submodule;
}
