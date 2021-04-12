{ writeScript, python3, nix-prefetch-github, nix-prefetch-git, ... }:

writeScript "bump-version.py" ''
  #!${python3}/bin/python

  import json
  import re
  import subprocess
  from sys import argv

  version = {
      "elixir-ls": "v0.7.0",
      "erlang-ls": "0.13.0",
      "emoji": "master",
  }

  location = {
      "elixir-ls": "packages/elixir-lsp/source.json",
      "erlang-ls": "packages/erlang-ls/source.json",
      "emoji": "packages/rofi-unicode/rofi-unicode.json",
  }

  repo_url = {
      "elixir-ls": ("elixir-lsp", "elixir-ls"),
      "erlang-ls": ("erlang-ls", "erlang_ls"),
      "emoji": "https://git.teknik.io/matf/rofiemoji-rofiunicode.git",
  }

  def github(name, rev, file):
      bin = "${nix-prefetch-github}/bin/nix-prefetch-github"
      owner, repo = repo_url[name]
      data = json.loads(subprocess.check_output([bin, "--rev", rev, owner, repo]))
      data["version"] = re.sub("^v", "", rev)
      with open(file, "w") as f:
          json.dump(data, f, indent=2, sort_keys=True)
          f.write("\n")

  def git(name, rev, file):
      bin = "${nix-prefetch-git}/bin/nix-prefetch-git"
      url = repo_url[name]
      data = json.loads(subprocess.check_output([bin, url]))
      data["version"] = re.sub("^v", "", rev)
      with open(file, "w") as f:
          json.dump(data, f, indent=2, sort_keys=True)
          f.write("\n")

  fetcher = {
      "elixir-ls": github,
      "erlang-ls": github,
      "emoji": git,
  }

  name = argv[1]

  fetcher[name](name, version[name], location[name])
''
