{ beamPackages, sources, fetchFromGitHub, git, cacert }:

beamPackages.rebar3Relx rec {
  name = "erlang-ls";
  version = sources.erlang-ls.branch;
  releaseType = "escript";

  buildInputs = [ git ];

  GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  src = fetchFromGitHub {
    name = "source-${name}-${version}";
    inherit (sources.erlang-ls) owner repo rev sha256;
  };
}
