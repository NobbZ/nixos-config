{ stdenv, erlang, rebar3, lib, rebar3Relx, fetchFromGitHub, git, cacert }:
let
  source = builtins.fromJSON (builtins.readFile ./source.json);

  fetchRebar3Deps =
    { name, version, sha256, src, meta ? { } }:

    stdenv.mkDerivation ({
      name = "rebar-deps-${name}-${version}";

      buildInputs = [ git cacert ];

      phases = [ "downloadPhase" "installPhase" ];

      downloadPhase = ''
        cp ${src} .
        HOME='.' DEBUG=1 ${rebar3}/bin/rebar3 get-deps
      '';

      installPhase = ''
        mkdir -p "$out/_checkouts"
        for i in ./_build/default/lib/* ; do
          echo "$i"
          rm -rf "$i"/.git
          cp -R "$i" "$out/_checkouts"
        done
      '';

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = sha256;

      # impureEnvVars = lib.fetchers.proxyImpureEnvVars;
      inherit meta;
    });
in
rebar3Relx rec {
  name = "erlang-ls";
  version = "${source.version}-${erlang.version}";
  releaseType = "escript";

  checkouts = fetchRebar3Deps {
    inherit name version;
    src = "${src}/rebar.lock";
    sha256 = "sha256-QNSnRGHHWMlngZfHugBdF0FpyuvcuTIgoQKrUWNIfxE=";
  };

  postPatch = ''
    substituteInPlace src/erlang_ls.app.src \
      --replace '{vsn, git}' '{vsn, "${version}"}'
  '';

  src = fetchFromGitHub {
    name = "source-${name}-${version}";
    inherit (source) owner repo rev sha256;
  };
}
