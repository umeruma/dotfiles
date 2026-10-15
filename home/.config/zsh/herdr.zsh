# herdr dev layouts, ported to zsh from Omarchy's default/bash/fns/herdr.
# Source: https://github.com/omacom/omarchy — MIT License, Copyright (c) David Heinemeier Hansson.
# hdl  <agent> [agent2]  editor (nvim) left, agent right, terminal bottom — in this tab
# hdlm <agent> [agent2]  one hdl tab per subdirectory of $PWD
# hsl  <count> <command> N panes tiled, same command in each
# Requires: herdr, jq. `hds` (hunk + opencode) is intentionally not ported.

# Echo a split ratio as a float: _herdr_ratio <numerator> <denominator>
_herdr_ratio() {
  awk -v a="$1" -v b="$2" 'BEGIN { printf "%.4f", a / b }'
}

# Split a pane and echo the new pane id: _herdr_split <pane_id> <right|down> <ratio> <cwd>
_herdr_split() {
  herdr pane split "$1" --direction "$2" --ratio "$3" --cwd "$4" --no-focus |
    jq -r '.result.pane.pane_id'
}

hdl() {
  [[ -z $1 ]] && { echo "Usage: hdl <agent> [<second_agent>]"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hdl."; return 1; }

  local current_dir="$PWD"
  local editor_pane="$HERDR_PANE_ID" ai_pane ai2_pane
  local ai="$1" ai2="${2:-}"

  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null

  # terminal: bottom 15%
  _herdr_split "$editor_pane" down 0.85 "$current_dir" >/dev/null
  # agent: right 30%
  ai_pane=$(_herdr_split "$editor_pane" right 0.7 "$current_dir")

  if [[ -n $ai2 ]]; then
    ai2_pane=$(_herdr_split "$ai_pane" down 0.5 "$current_dir")
    herdr pane run "$ai2_pane" "$ai2" >/dev/null
  fi

  herdr pane run "$ai_pane" "$ai" >/dev/null
  herdr pane run "$editor_pane" "nvim ." >/dev/null
}

hdlm() {
  [[ -z $1 ]] && { echo "Usage: hdlm <agent> [<second_agent>]"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hdlm."; return 1; }

  local ai="$1" ai2="${2:-}"
  local base_dir="$PWD" first=true hdl_command dir dirpath pane_id

  herdr workspace rename "$HERDR_WORKSPACE_ID" "$(basename "$base_dir")" >/dev/null

  for dir in "$base_dir"/*(N/); do
    dirpath="${dir%/}"
    printf -v hdl_command 'hdl %q' "$ai"
    [[ -n $ai2 ]] && printf -v hdl_command '%s %q' "$hdl_command" "$ai2"

    if $first; then
      printf -v hdl_command 'cd %q && %s' "$dirpath" "$hdl_command"
      herdr pane run "$HERDR_PANE_ID" "$hdl_command" >/dev/null
      first=false
    else
      pane_id=$(herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$dirpath" --no-focus |
        jq -r '.result.root_pane.pane_id')
      herdr pane run "$pane_id" "$hdl_command" >/dev/null
    fi
  done
}

hsl() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: hsl <pane_count> <command>"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hsl."; return 1; }

  local count="$1" cmd="$2" current_dir="$PWD"
  local -a columns panes
  local cols=1 k index col rows j last pane

  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null

  # grid: ceil(sqrt(count)) columns
  while (( cols * cols < count )); do (( cols++ )); done

  # split the rightmost column off at 1/(n-k+1) each time → even widths, left-to-right order
  columns=("$HERDR_PANE_ID")
  for (( k = 1; k < cols; k++ )); do
    columns+=("$(_herdr_split "${columns[-1]}" right "$(_herdr_ratio 1 $((cols - k + 1)))" "$current_dir")")
  done

  # rows per column, top-to-bottom
  for (( index = 0; index < cols; index++ )); do
    col="${columns[index + 1]}"   # zsh arrays are 1-based
    rows=$(( count / cols ))
    (( index < count % cols )) && (( rows++ ))
    panes+=("$col")
    last="$col"
    for (( j = 1; j < rows; j++ )); do
      last=$(_herdr_split "$last" down "$(_herdr_ratio 1 $((rows - j + 1)))" "$current_dir")
      panes+=("$last")
    done
  done

  for pane in "${panes[@]}"; do
    herdr pane run "$pane" "$cmd" >/dev/null
  done
}
