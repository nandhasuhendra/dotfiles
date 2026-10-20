#!/usr/bin/env bash
set -euo pipefail

OMP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "$WORK_DIR"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
STAMP=20000101-000000
shopt -s nullglob

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
status() { printf '  %s %s\n' "$1" "$2"; }
stage() { :; }

# ponytail: deployment extraction uses installer boundary markers; update them here if that block moves.
deployment='' extracting=false complete=false
while IFS= read -r line; do
  if [[ "$line" == 'link_config() {' ]]; then
    extracting=true
  elif [[ "$extracting" == true && "$line" == "printf '\\n%sInstallation complete"* ]]; then
    complete=true
    break
  fi
  if [[ "$extracting" == true ]]; then
    deployment+="$line"$'\n'
  fi
done < "$OMP_DIR/install-omp.sh"
[[ "$complete" == true ]] || fail 'Cannot locate complete installer deployment block'
printf '%s' "$deployment" > "$WORK_DIR/deployment.sh"

assert_installed() {
  local item rule
  for item in config.yml mcp.json agents commands RULES.md rules templates; do
    [[ -L "$CONFIG_DIR/$item" ]] || fail "Missing link: $item"
    [[ "$(readlink "$CONFIG_DIR/$item")" == "$OMP_DIR/$item" ]] || fail "Wrong target: $item"
    [[ -r "$CONFIG_DIR/$item" ]] || fail "Unreadable installed path: $item"
  done
  cmp "$OMP_DIR/RULES.md" "$CONFIG_DIR/RULES.md"
  for rule in core.md planning.md gates.md execution.md verification.md; do
    [[ -r "$CONFIG_DIR/rules/$rule" ]] || fail "Unreadable installed rule: $rule"
    cmp "$OMP_DIR/rules/$rule" "$CONFIG_DIR/rules/$rule"
    printf '  Read installed rules/%s\n' "$rule"
  done
  for item in skills extensions; do
    if [[ -e "$OMP_DIR/$item" ]]; then
      [[ -L "$CONFIG_DIR/$item" && "$(readlink "$CONFIG_DIR/$item")" == "$OMP_DIR/$item" ]] \
        || fail "Optional configuration link changed: $item"
    fi
  done
}

printf 'original rules sentinel\n' > "$WORK_DIR/original"
printf 'occupied backup sentinel\n' > "$WORK_DIR/occupied"
for scenario in fresh existing collision; do
  CONFIG_DIR="$WORK_DIR/$scenario config"
  mkdir -p "$CONFIG_DIR"
  if [[ "$scenario" != fresh ]]; then
    mkdir "$CONFIG_DIR/rules"
    cp "$WORK_DIR/original" "$CONFIG_DIR/rules/sentinel"
  fi
  if [[ "$scenario" == collision ]]; then
    mkdir "$CONFIG_DIR/rules.backup.$STAMP"
    cp "$WORK_DIR/occupied" "$CONFIG_DIR/rules.backup.$STAMP/sentinel"
  fi
  printf 'Deploy %s: %s (timestamp %s)\n' "$scenario" "$CONFIG_DIR" "$STAMP"
  source "$WORK_DIR/deployment.sh"
  assert_installed
  backups=("$CONFIG_DIR/"*.backup.*)
  case "$scenario" in
    fresh)
      [[ ${#backups[@]} == 0 ]] || fail 'Fresh deployment created backups'
      ;;
    existing)
      [[ ${#backups[@]} == 1 ]] || fail 'Expected one existing-rules backup'
      cmp "$WORK_DIR/original" "$CONFIG_DIR/rules.backup.$STAMP/sentinel"
      ;;
    collision)
      [[ ${#backups[@]} == 2 ]] || fail 'Expected two distinct rules backups'
      cmp "$WORK_DIR/occupied" "$CONFIG_DIR/rules.backup.$STAMP/sentinel"
      cmp "$WORK_DIR/original" "$CONFIG_DIR/rules.backup.$STAMP.1/sentinel"
      ;;
  esac
  printf '  Preserved backups: %s\n' "${backups[@]}"
  printf '%s\n' "${backups[@]}" > "$WORK_DIR/backups-before"
  source "$WORK_DIR/deployment.sh"
  assert_installed
  backups=("$CONFIG_DIR/"*.backup.*)
  printf '%s\n' "${backups[@]}" > "$WORK_DIR/backups-after"
  cmp "$WORK_DIR/backups-before" "$WORK_DIR/backups-after"
  if [[ "$scenario" == existing ]]; then
    cmp "$WORK_DIR/original" "$CONFIG_DIR/rules.backup.$STAMP/sentinel"
  elif [[ "$scenario" == collision ]]; then
    cmp "$WORK_DIR/occupied" "$CONFIG_DIR/rules.backup.$STAMP/sentinel"
    cmp "$WORK_DIR/original" "$CONFIG_DIR/rules.backup.$STAMP.1/sentinel"
  fi
  printf 'PASS: %s deployment and matching-link repeat\n' "$scenario"
done
