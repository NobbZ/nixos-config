{ beamPackages
, callPackage
, elixir
, fetchFromGitHub
, gitMinimal
, rebar3
, sources
, stdenv
, fetchMixDeps ? callPackage ./fetch-mix-deps.nix { }
, hex ? beamPackages.hex
}:

stdenv.mkDerivation rec {
  name = sources.elixir-ls.repo;
  version = sources.elixir-ls.rev;

  nativeBuildInputs = [ elixir hex gitMinimal deps ];

  deps = fetchMixDeps { inherit name version src; };

  # refresh: nix-prefetch-git https://github.com/elixir-lsp/elixir-ls.git [--rev branchName | --rev sha]
  src = fetchFromGitHub {
    name = "source-${name}-${version}";
    inherit (sources.elixir-ls) owner repo rev sha256;
  };

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
