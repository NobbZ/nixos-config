{ pkgs, stdenv, elixir, beamPackages, rebar3, hex ? beamPackages.hex
, fetchFromGitHub, fetchMixDeps ? pkgs.callPackage ./fetch-mix-deps.nix { }
, gitMinimal }:

let
  json = {
    owner = "elixir-lsp";
    repo = "elixir-ls";
    rev = "ce36476131566db3fc5ae67a44bfe5d630431f50";
    sha256 = "00iwaqrdv99cgq0l8b1hq5yfs45idqq9mrqpri2camipnx2639dl";
  };
in stdenv.mkDerivation rec {
  name = "elixir-ls";
  version = json.rev;

  nativeBuildInputs = [ elixir hex gitMinimal deps ];

  deps = fetchMixDeps { inherit name version src; };

  # refresh: nix-prefetch-git https://github.com/elixir-lsp/elixir-ls.git [--rev branchName | --rev sha]
  src = fetchFromGitHub json;

  dontStrip = true;

  configurePhase = ''
    runHook preConfigure
    export HEX_OFFLINE=1
    export MIX_HOME=`pwd`

    cp --no-preserve=all -R ${deps}/deps deps
    mix local.rebar rebar3 ${rebar3}/bin/rebar3
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    export MIX_ENV=prod

    mix elixir_ls.release

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -Rv release $out/lib
    substitute release/language_server.sh $out/bin/language_server.sh \
    --replace "ERL_LIBS=\"\$SCRIPTPATH:\$ERL_LIBS\"" "ERL_LIBS=$out/lib:\$ERL_LIBS" \
    --replace "elixir -e" "${elixir}/bin/elixir -e"
    chmod +x $out/bin/language_server.sh
    mv $out/bin/language_server.sh $out/bin/elixir-ls
  '';
}
