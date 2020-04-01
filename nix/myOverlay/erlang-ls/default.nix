{ beamPackages, sources, fetchFromGitHub }:

beamPackages.rebar3Relx {
  name = "erlang-ls";
  version = sources.erlang-ls.branch;
  releaseType = "escript";

  src = fetchFromGitHub { inherit (sources.erlang-ls) owner repo rev sha256; };
}
