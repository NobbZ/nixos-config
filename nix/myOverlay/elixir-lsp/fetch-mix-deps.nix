{ cacert, elixir, gitMinimal, lib, rebar3, stdenv, }:

{ name, version, sha256 ? lib.fakeSha256, src, env ? "prod" }:

with stdenv;

mkDerivation {
  name = "mix-deps-${name}-${version}";

  nativeBuildInputs = [ elixir gitMinimal cacert ];

  phases = [ "downloadPhase" "installPhase" ];

  downloadPhase = ''
    export HEX_HOME=$PWD
    export MIX_HOME=$PWD
    export MIX_ENV=${env}

    cp -R ${src}/* .

    mix local.hex --force
    mix local.rebar rebar3 ${rebar3}/bin/rebar3
    mix deps.get
  '';

  installPhase = ''
    mkdir -p "$out"
    cp -R deps "$out"
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  impureEnvVars = lib.fetchers.proxyImpureEnvVars;
}
