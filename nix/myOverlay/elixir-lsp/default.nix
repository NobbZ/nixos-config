{ pkgs, fetchFromGitHub, fetchHex, beamPackages
, buildMix ? beamPackages.buildMix, buildRebar3 ? beamPackages.buildRebar3, ...
}:

let
  dialyxir = buildMix rec {
    name = "dialyxir";
    version = "1.0.0-rc.7";

    src = fetchHex {
      pkg = name;
      inherit version;
      sha256 = "08kih8v66sm0as93y17bxmds7s5c36nswlj85llfbr23qpb98qjh";
    };
  };

  elixirSense = buildMix rec {
    name = "elixir_sense";
    version = "";
    src = fetchFromGitHub {
      owner = "elixir-lsp";
      repo = name;
      rev = "9531d0e90652d3baf906ad4553d0d17baf4096f5";
      sha256 = "0fd5ardqzcgnz6wh9iyyrpaylnz5wv9bgc5r0m33qpsjiznl8h03";
    };
  };

  erl2Ex = buildMix rec {
    name = "erl2ex";
    version = "";
    src = fetchFromGitHub {
      owner = "dazuma";
      repo = name;
      rev = "244c2d9ed5805ef4855a491d8616b8842fef7ca4";
      sha256 = "1z4fwcgxf847vffwnw4h6yallpnzjbn8ff6dvh53k7vr6h17l4vf";
    };
  };

  erlex = buildMix rec {
    name = "erlex";
    version = "0.2.5";

    src = fetchHex {
      pkg = name;
      inherit version;
      sha256 = "1y7vk575gx5b0cd2s3lxrxlc9nn5abbzs5dpfkv9lcsnn0ckwvbm";
    };
  };

  jason = buildMix rec {
    name = "jason";
    version = "1.1.2";

    src = fetchHex {
      pkg = name;
      inherit version;
      sha256 = "1zispkj3s923izkwkj2xvaxicd7m0vi2xnhnvvhkl82qm2y47y7x";
    };
  };

  forms = buildRebar3 rec {
    name = "forms";
    version = "0.0.1";

    src = fetchHex {
      pkg = name;
      inherit version;
      sha256 = "0s2qg5mn7d01h7sbx7fik5l4jdifrdlvsxgw8kvp38fmivnn63sk";
    };
  };

  mixTaskArchiveDeps = buildMix rec {
    name = "mix_task_archive_deps";
    version = "";
    src = fetchFromGitHub {
      owner = "JakeBecker";
      repo = name;
      rev = "50301a4314e3cc1104f77a8208d5b66ee382970b";
      sha256 = "1mrk9hgalwz38x598w0r4pdgqyc2ra8n0qfpwyykh1gq1nwgp5s5";
    };
  };
in buildMix rec {
  name = "elixir-lsp";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "elixir-lsp";
    repo = "elixir-ls";
    rev = "v${version}";
    sha256 = "0yxma786nscl81jsghm1mix62kmm4h0bmgkmy35zz6svs1s33fzc";
  };

  nativeBuildInputs = with pkgs; [ elixir ];
  beamDeps =
    [ dialyxir elixirSense erl2Ex erlex forms jason mixTaskArchiveDeps ];

  #   phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  #   configurePhase = ''
  #     runHook preConfigure
  #     export HEX_OFFLINE=1
  #     export MIX_HOME=`pwd`

  #     cp --no-preserve=all -R ${deps}/deps deps
  #     mix local.rebar rebar3 ${rebar3}/bin/rebar3
  #     runHook postConfigure
  #   '';

  buildPhase = ''
    runHook preBuild
    export HEX_OFFLINE=1
    export HEX_HOME=`pwd`
    export MIX_ENV=prod
    export MIX_NO_DEPS=1
    mix compile --no-deps-check
    mix elixir_ls.release --no-deps-check
    runHook postBuild
  '';

  installPhase = ''
    ls -la releases
    exit 1
  '';
}
