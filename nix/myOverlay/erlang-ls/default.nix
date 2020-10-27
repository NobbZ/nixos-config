{ beamPackages, rebar3Relx, sources, fetchFromGitHub, git, cacert, pkgs }:

rebar3Relx rec {
  name = "erlang-ls";
  version = sources.erlang-ls.branch;
  releaseType = "escript";

  buildInputs = [ git ];

  GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  # checkouts = beamPackages.fetchRebar3Deps {
  #   inherit name version;
  #   src = "${src}/rebar.lock";
  #   sha256 = pkgs.lib.fakeSha256;
  # };

  preBuild = ''
    HOME=$(pwd) rebar3 get-deps
  '';

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "0b2mkyqplhz46ldyhpggd1z34kipj59cmh9a469i02zcfdjl3xhc";

  src = fetchFromGitHub {
    name = "source-${name}-${version}";
    inherit (sources.erlang-ls) owner repo rev sha256;
  };
}
