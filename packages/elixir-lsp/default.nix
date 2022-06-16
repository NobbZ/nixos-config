{
  stdenv,
  erlang,
  elixir,
  rebar3,
  hex,
  callPackage,
  git,
  cacert,
  fetchFromGitHub,
}: let
  fetchMixDeps = callPackage ./fetch-mix-deps.nix {inherit rebar3;};

  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  stdenv.mkDerivation (self: {
    name = "elixir-ls";
    version = "${source.version}-${erlang.version}-${elixir.version}";

    nativeBuildInputs = [elixir hex git cacert];
    buildInputs = [self.deps];

    deps = fetchMixDeps {
      name = "${self.name}-${self.version}";
      inherit (self) src;
      sha256 = "sha256-8MOV2a/C5uO5Q1S97XY8VP0bJI4ByFRIIHNwRtG94cs=";
    };

    src = fetchFromGitHub rec {
      name = "source-${owner}-${repo}-${self.version}";
      inherit (source) owner repo rev sha256;
    };

    dontStrip = true;

    HEX_OFFLINE = "1";
    HEX_HOME = "/build/${self.src.name}/hex";
    MIX_ENV = "prod";
    MIX_HOME = "/build/${self.src.name}";
    MIX_REBAR3 = "${rebar3}/bin/rebar3";
    REBAR_GLOBAL_CONFIG_DIR = "/build/${self.src.name}/rebar3";
    REBAR_CACHE_DIR = "/build/§{self.src.name}/rebar3.cache";

    configurePhase = ''
      cp --no-preserve=all -R ${self.deps} deps
      mix deps.compile --no-deps-check
    '';

    buildPhase = ''
      mix do compile --no-deps-check, elixir_ls.release
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp -Rv release $out/lib
      # Prepare the wrapper script
      substitute release/language_server.sh $out/bin/elixir-ls \
        --replace 'exec "''${dir}/launch.sh"' "exec $out/lib/launch.sh"
      chmod +x $out/bin/elixir-ls
      # prepare the launcher
      substituteInPlace $out/lib/launch.sh \
        --replace "elixir" "${elixir}/bin/elixir" \
        --replace "ERL_LIBS=\"\$SCRIPTPATH:\$ERL_LIBS\"" \
                  "ERL_LIBS=$out/lib:\$ERL_LIBS"
    '';
  })
