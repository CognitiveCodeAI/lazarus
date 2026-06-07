#!/usr/bin/env bash
# PreToolUse hook for the Lazarus plugin.
#
# Blocks destructive bash commands BEFORE they execute. Claude Code passes the
# tool input as JSON on stdin; this script extracts .tool_input.command PRECISELY
# via the first available of jq / python3 / python / perl (never coarse text
# scanning). If NONE of those parsers exist it FAILS CLOSED -- it blocks every
# bash command with an explanatory message rather than letting commands through
# unchecked.
#
# Exit 2 = deny (stderr is shown to the model). Exit 0 = allow.
# Customize PATTERN for your environment.

set -u

INPUT=$(cat)

# Extract .tool_input.command with whichever JSON parser is present.
# Returns non-zero (3) if no parser is available, or propagates a parser error.
extract_command() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$INPUT" | jq -r '.tool_input.command // empty'
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$INPUT" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("tool_input",{}).get("command",""))'
  elif command -v python >/dev/null 2>&1; then
    printf '%s' "$INPUT" | python -c 'import sys,json;print(json.load(sys.stdin).get("tool_input",{}).get("command",""))'
  elif command -v perl >/dev/null 2>&1; then
    printf '%s' "$INPUT" | perl -0777 -MJSON::PP -e 'print((decode_json(<>)->{tool_input}{command}) // "")'
  else
    return 3
  fi
}

if ! CMD=$(extract_command); then
  echo "BLOCKED: destructive-command hook requires jq, python3, or perl to parse tool input, but none are installed. Install one, or run the command manually outside Claude Code." >&2
  exit 2
fi

PATTERN='(rm -rf /|rm -rf ~|rm -rf \$HOME|:\(\)\{|mkfs\.|dd if=.*of=/dev/(sd|nvme|hd)|>\s*/dev/(sd|nvme|hd)|chmod -R 000|chown -R.*:.*/$|git push([[:space:]][^|;&]*)?[[:space:]](-f|--force(-with-lease)?)([[:space:]]|$)|git reset --hard origin|git clean -fdx|prisma migrate reset|prisma db push --force-reset|DROP\s+(DATABASE|TABLE|SCHEMA)|TRUNCATE\s+TABLE|DELETE\s+FROM\s+\w+\s*;|kubectl delete (ns|namespace|pv|pvc|deployment|statefulset)|docker system prune -af|docker volume rm|aws s3 rb|aws rds delete|aws ec2 terminate|terraform destroy|terraform apply.*-auto-approve|npm publish|pnpm publish|cargo publish|gh repo delete|firebase deploy --only hosting)'

if printf '%s' "$CMD" | grep -iqE "$PATTERN"; then
  echo "BLOCKED: This command matches a destructive pattern that requires human confirmation. If you are sure this is intended, run it manually outside of Claude Code." >&2
  exit 2
fi

exit 0
