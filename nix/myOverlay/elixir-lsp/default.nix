{ sources, stdenv, elixir, rebar3, hex, callPackage, git, cacert, fetchFromGitHub }:
let
  fetchMixDeps = callPackage ./fetch-mix-deps.nix { };
in
stdenv.mkDerivation rec {
  name = "elixir-ls";
  version = "0.6.0"; # TODO: get this from the JSON

  nativeBuildInputs = [ elixir hex git deps cacert ];

  deps = fetchMixDeps {
    name = "${name}-${version}";
    inherit src;
    sha256 = "sha256-nOTzXJnT093DeMzraQRplLwgk9Xg03Tn28xICMTDvq0=";
  };

  src = fetchFromGitHub rec {
    name = "source-${owner}-${repo}-${version}";
    inherit (builtins.fromJSON (builtins.readFile ./source.json)) owner repo rev sha256;
  };

  dontStrip = true;

  configurePhase = ''
    export MIX_ENV=prod
    export HEX_OFFLINE=1
    export HEX_HOME="$PWD/hex"
    export MIX_HOME="$PWD"
    export MIX_REBAR3="${rebar3}/bin/rebar3"
    export REBAR_GLOBAL_CONFIG_DIR="$PWD/rebar3"
    export REBAR_CACHE_DIR="$PWD/rebar3.cache"
    cp --no-preserve=all -R ${deps} deps
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
      --replace "ERL_LIBS=\"\$SCRIPTPATH:\$ERL_LIBS\"" \
                "ERL_LIBS=$out/lib:\$ERL_LIBS" \
      --replace "elixir -e" "${elixir}/bin/elixir -e"
  '';
}
