#!/bin/sh
# SessionStart / SessionEnd hook: tell the terminal how to bring this Claude
# session back after a restart (OSC 7577, https://www.superlogical.com/rex/docs/build/program-resume).
# Remove once Claude Code reports it itself (docs/src/content/docs/editor-stack.mdx).
[ -n "$OSC7577_TOKEN" ] || exit 0
input=$(cat)
field() { printf '%s' "$input" | /usr/bin/jq -r ".$1 // empty"; }

# The report names Claude's pid, not this hook's; claude runs it through a shell.
pid=$PPID
i=0
while [ "$i" -lt 5 ] && [ "$(ps -o comm= -p "$pid" | xargs basename 2>/dev/null)" != claude ]; do
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
  i=$((i + 1))
done
[ "$(ps -o comm= -p "$pid" | xargs basename 2>/dev/null)" = claude ] || exit 0

b64() { printf '%s' "$1" | /usr/bin/base64 | tr -d '\n'; }
case $(field hook_event_name) in
  SessionStart)
    sid=$(field session_id)
    cwd=$(field cwd)
    [ -n "$sid" ] && [ -n "$cwd" ] || exit 0
    body="pid=$pid:time=$(date +%s):argv=$(b64 claude),$(b64 --resume),$(b64 "$sid"):cwd=$(b64 "$cwd")"
    ;;
  SessionEnd)
    # Only a deliberate exit clears; a terminal restart must keep the record.
    case $(field reason) in prompt_input_exit | logout) ;; *) exit 0 ;; esac
    body="pid=$pid:time=$(date +%s):clear=1"
    ;;
  *) exit 0 ;;
esac

# Hooks have no controlling terminal, so write to claude's tty device instead of /dev/tty.
tty=$(ps -o tty= -p "$pid" | tr -d ' ')
[ -w "/dev/$tty" ] || exit 0
# printf is a builtin, so the token does not show up in the process list.
mac=$(printf '%s:%s' "$body" "$OSC7577_TOKEN" | /usr/bin/shasum -a 256 | cut -c1-64)
# shellcheck disable=SC1003
printf '\033]7577;%s:mac=%s\033\\' "$body" "$mac" >"/dev/$tty"
exit 0
