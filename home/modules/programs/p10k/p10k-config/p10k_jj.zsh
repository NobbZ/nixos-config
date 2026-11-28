# The content of this file is inspired by the blogpost at
# https://zerowidth.com/2025/async-zsh-jujutsu-prompt-with-p10k/

typeset -g _my_jj_display=""
typeset -g _my_jj_workspace=""

_my_jj_async() {
  local workspace=$1
  local change_id

  change_id=$(jj log --repository "$workspace" --ignore-working-copy \
    --no-graph --limit 1 --color always \
    --revisions @ -T 'change_id.shortest(3)')

  display=$(echo "$change_id" | sed 's/\x1b\[[0-9;]*m/%{&%}/g')
}

_my_jj_callback() {
  local job_name=$1 exit_code=$2 output=$3 exeecution_time=$4 stderr=$5 next_pending=$6

  if [[ $exit_code == 0 ]]; then
    _my_jj_display=$output
  else
    _my_jj_display="$output %F{red}$stderr%f"
  fi

  p10k display -r
}
