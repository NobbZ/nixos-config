_: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.profiles.development;
in {
  options.profiles.development = {
    enable =
      lib.mkEnableOption
      "A profile that enables the system to be used for developing programs";
  };

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          inherit (config.programs.git.settings.user) name email;
        };

        ui.diff-formatter = [config.programs.git.settings.diff.external "--color=always" "$left" "$right"];
        ui.paginate = "never";
      };
    };

    programs.gh.enable = true;
    programs.git = {
      enable = true;

      settings.user.name = "Norbert Melzer";
      settings.user.email = "timmelzer@gmail.com";

      settings.alias = let
        mkFixupAlias = command:
          pkgs.resholve.writeScript "git-${command}" {
            inputs = builtins.attrValues {inherit (pkgs) git fzf ripgrep;};
            interpreter = "${pkgs.bash}/bin/bash";
            execer = ["cannot:${pkgs.git}/bin/git" "cannot:${pkgs.fzf}/bin/fzf"];
          }
          # bash
          ''
            git log --graph --color=always --format="%C(auto)%h%d %s0x09%C(white)%C(bold)%cr" "$@" |
              fzf --ansi --no-sort --reverse --tiebreak=index \
                --bind=ctrl-s:toggle-sort \
                --bind="ctrl-m:execute:(rg -o '\b[a-f0-9]{6,}\b' | head -1 | xargs -I% sh -c 'git commit --${command}=% | less -R') <<FZF-EOF
                {}
            FZF-EOF"
          '';
        gitSwitchFzf =
          pkgs.resholve.writeScript "git-switch-fzf" {
            inputs = builtins.attrValues {inherit (pkgs) git fzf coreutils gawk;};
            interpreter = "${pkgs.bash}/bin/bash";
            execer = ["cannot:${pkgs.git}/bin/git" "cannot:${pkgs.fzf}/bin/fzf"];
          }
          # bash
          ''
            # Function to determine the ref type
            function get_ref_type() {
                local ref="$1"
                if git show-ref --verify --quiet refs/heads/"$ref"; then
                    echo "branch"
                elif git show-ref --verify --quiet refs/tags/"$ref"; then
                    echo "tag"
                elif git rev-parse --verify --quiet "$ref" >/dev/null; then
                    echo "commit"
                else
                    echo "unknown"
                fi
            }

            # Function to select a ref using fzf
            function select_ref_with_fzf() {
                cat <(git branch --format='%(refname:short) [branch]') \
                    <(git tag --format='%(refname:short) [tag]') \
                    <(git log --pretty=format:'%h %s [commit]') \
                | fzf
            }

            # If the first argument is -c or -C, forward the arguments as-is to git switch
            if [ "$#" -ge 2 ] && ([[ "$1" == "-c" ]] || [[ "$1" == "-C" ]]); then
                git switch "$@"
            else
                # If an argument is provided and it's not -c or -C, switch to the specified ref
                if [ "$#" -eq 1 ]; then
                    ref_name="$1"
                    ref_type=$(get_ref_type "$ref_name")

                    if [ "$ref_type" == "unknown" ]; then
                        echo "Invalid ref: $ref_name" >&2
                        exit 1
                    fi
                else
                    # If no argument or only -c/-C is provided, use the fzf selection interface to select a ref
                    selected_ref=$(select_ref_with_fzf)

                    # Extract the ref name and type from the selected_ref string
                    ref_name=$(echo "$selected_ref" | awk '{print $1}')
                    ref_type=$(echo "$selected_ref" | awk '{print $NF}' | tr -d '[]')
                fi

                # Based on the ref type, issue the appropriate git switch command
                case "$ref_type" in
                  branch)
                    git switch "$ref_name"
                    ;;
                  tag)
                    git switch --detach "$ref_name"
                    ;;
                  commit)
                    git switch --detach "$ref_name"
                    ;;
                  *)
                    # If an invalid ref type is encountered, print an error message and exit
                    echo "Invalid ref type: $ref_type" >&2
                    exit 1
                    ;;
                esac
            fi
          '';
      in {
        br = "branch";
        co = "checkout";
        vommit = "commit";
        vomit = "commit";
        graph = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold cyan)%h%C(reset) - %C(green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
        pl = "pull";
        ps = "push";
        psf = "push --force-with-lease";
        root = "rev-parse --show-toplevel";
        st = "status";
        sw = "!${gitSwitchFzf}";
        swag = ''!f() { if [ -z "$1" ]; then tag=$(git describe --abbrev=0 --tag); else tag=$(git describe --abbrev=0 --tag "$1"); fi; git switch --detach "''${tag}"; }; f'';
        hopbase = ''!f() { set -o nounset; tag=$(git describe --abbrev=0 --tag "$1") && git rebase -i "''${tag}"; }; f'';
        comfix = "!${mkFixupAlias "fixup"}";
        comreb = "!${mkFixupAlias "rebase"}";
        show = "show --ext-diff";
        lp = "log -p --ext-diff";
      };

      settings = {
        init.defaultBranch = "main";
        diff.external = lib.getExe pkgs.difftastic;
        pull.rebase = false;
        merge.conflictStyle = "diff3";
        merge.mergiraf.name = "mergiraf";
        merge.mergiraf.driver = ''${lib.getExe pkgs.mergiraf} merge --git "%O" "%A" "%B" -s "%S" -x "%X" -y "%Y" -p "%P" -l "%L"'';
        rerere.enabled = true;
      };

      attributes = [
        "* merge=mergiraf"
      ];

      ignores = [
        # IntelliJ files and folders
        ".idea/"
        "*.iml"
        # backupfiles and shadow copies done by editors
        "*~"
        "\\#*\\#"
        ".#*"
        # Elixir language server
        "/.elixir_ls"
        # MyPy Cache
        ".mypy_cache"
        # Visual Studio Code project configuration
        "/.vscode"
        # Result folder for nix builds
        "result"
        "result-*"
        # direnv caches
        ".direnv/"
        # emacs/python stuff
        "flycheck_*.py"
      ];

      includes = [
        {
          condition = "gitdir:~/cloudseeds/**";
          contents = {
            init.defaultBranch = "master";
            user.email = "norbert.melzer@cloudseeds.de";
          };
        }
        {
          condition = "gitdir:~/Projects/BravoBike/**";
          contents = {
            user.email = "norbert.melzer@bravobike.de";
          };
        }
      ];
    };

    home.packages = [pkgs.ripgrep pkgs.difftastic];
  };
}
