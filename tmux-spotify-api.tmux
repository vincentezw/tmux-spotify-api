#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local option_name="$1"
  local default_value="$2"
  local option_value=$(tmux show-option -gqv $option_name)

  if [ -z "$option_value" ]; then
    echo -n $default_value
  else
    echo -n $option_value
  fi
}

set_tmux_option() {
  local option_name="$1"
  local option_value="$2"
  $(tmux set-option -gq $option_name "$option_value")
}

replace_placeholder_in_status_line() {
  local placeholder="\#{$1}"
  local script="#($2)"
  local status_line_side=$3
  local old_status_line=$(get_tmux_option $status_line_side)
  local new_status_line=${old_status_line/$placeholder/$script}

  $(set_tmux_option $status_line_side "$new_status_line")
}

main() {
  local now_playing="cd "$CURRENT_DIR" && ./spotify.rb"
  replace_placeholder_in_status_line "now_playing" "$now_playing" "status-right"
}

main

