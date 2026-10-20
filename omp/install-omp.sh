#!/usr/bin/env bash
set -euo pipefail

OMP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}"
PREFIX="${NPM_CONFIG_PREFIX:-$HOME/.local}"
STAMP="$(date +%Y%m%d-%H%M%S)"
export PATH="$PREFIX/bin:$PATH"
BOLD='' RESET='' CYAN='' GREEN='' YELLOW='' RED=''
if [[ -t 1 && "${TERM:-dumb}" != dumb && -z "${NO_COLOR+x}" ]]; then
  BOLD=$'\033[1m' RESET=$'\033[0m'
  CYAN=$'\033[36m' GREEN=$'\033[32m' YELLOW=$'\033[33m' RED=$'\033[31m'
fi

# Semantic colors use the terminal palette; text labels remain meaningful without color.
status() {
  local color=''
  case "$1" in
    RUN) color="$CYAN" ;;
    OK|READY|LINKED) color="$GREEN" ;;
    BACKUP|NOTICE) color="$YELLOW" ;;
    ERROR) color="$RED" ;;
  esac
  printf '  %s%-7s%s %s\n' "$color" "$1" "$RESET" "$2"
}
stage() { printf '\n%s%s[%s/5] %s%s\n' "$BOLD" "$CYAN" "$1" "$2" "$RESET"; }
die() {
  status ERROR "$*" >&2
  [[ -z "${LOG_FILE:-}" ]] || printf '  Full log: %s\n' "$LOG_FILE" >&2
  exit 1
}
run() {
  local label="$1"
  shift
  status RUN "$label"
  if "$@" >> "$LOG_FILE" 2>&1; then
    status OK "$label"
  else
    die "$label failed. See the full log, fix the cause, then rerun."
  fi
}

printf '\n%sOMP / Engineering workspace%s\n' "$BOLD" "$RESET"
printf '  Dependencies, agents and gated commands\n  Destination: %s\n' "$CONFIG_DIR"
stage 1 'Check prerequisites'
case "$(uname -s)" in
  Linux|Darwin) ;;
  *) die 'Supported systems: Linux and macOS.' ;;
esac
for tool in node npm omp curl git tar; do
  command -v "$tool" >/dev/null 2>&1 || die "Missing $tool. Install it and rerun."
done
node -e 'const [major, minor] = process.versions.node.split(".").map(Number); process.exit(major > 20 || (major === 20 && minor >= 19) ? 0 : 1)' \
  || die 'Node.js 20.19 or newer is required. Select a supported Node version and rerun.'
for item in mcp.json agents commands RULES.md rules templates skills; do
  [[ -e "$OMP_DIR/$item" ]] || die "Missing $OMP_DIR/$item"
done
for template in PRD.md TECH-DOC.md HUMAN-TASK-BREAKDOWN.md QA-TEST-CASES.md TASK-BREAKDOWN.md; do
  [[ -f "$OMP_DIR/templates/$template" ]] || die "Missing $OMP_DIR/templates/$template"
done
for rule in core.md planning.md gates.md execution.md verification.md; do
  [[ -f "$OMP_DIR/rules/$rule" ]] || die "Missing $OMP_DIR/rules/$rule"
done
[[ -f "$OMP_DIR/skills/caveman/SKILL.md" ]] || die 'Missing bundled Caveman skill at omp/skills/caveman/SKILL.md'
mkdir -p "$CONFIG_DIR/install-logs" "$PREFIX/bin"
LOG_FILE="$(mktemp "$CONFIG_DIR/install-logs/$STAMP.XXXXXX")"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "$WORK_DIR"' EXIT
trap 'die "Installation stopped at line $LINENO. Existing backups and full logs are preserved."' ERR
status OK "Node $(node --version); OMP $(omp --version)"
printf '  Full log: %s\n' "$LOG_FILE"

install_cli() {
  local command="$1" package="$2"
  if command -v "$command" >/dev/null 2>&1 && "$command" --version >> "$LOG_FILE" 2>&1; then
    status READY "$command"
  else
    run "Install $command" npm install --global --prefix "$PREFIX" --no-fund --no-audit "$package"
    hash -r
    run "Verify $command" "$command" --version
  fi
}

stage 2 'Install command-line dependencies'
install_cli openspec '@fission-ai/openspec@1.14.3'
install_cli codegraph '@colbymchenry/codegraph@1.6.2'
if command -v rtk >/dev/null 2>&1 && rtk --version >> "$LOG_FILE" 2>&1 && rtk gain >> "$LOG_FILE" 2>&1; then
  status READY 'rtk-ai (rtk)'
else
  command -v sha256sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1 \
    || die 'RTK requires sha256sum or shasum to verify release checksums.'
  run 'Download official RTK installer' curl -fsSL --connect-timeout 10 --max-time 60 \
    https://raw.githubusercontent.com/rtk-ai/rtk/v0.45.0/install.sh -o "$WORK_DIR/rtk-install.sh"
  run 'Install checksum-verified RTK' env RTK_VERSION=v0.45.0 RTK_SKIP_CHECKSUM=0 RTK_INSTALL_DIR="$PREFIX/bin" sh "$WORK_DIR/rtk-install.sh"
  run 'Verify rtk-ai identity' "$PREFIX/bin/rtk" gain
fi

stage 3 'Install Ponytail'
pony_installed() {
  omp plugin list --json > "$WORK_DIR/plugins.json" || return 1
  node - "$WORK_DIR/plugins.json" <<'NODE'
const fs = require('node:fs');
const plugins = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const plugin = (plugins.marketplace || []).find(p => p.id === 'ponytail@ponytail');
process.exit(plugin && plugin.entries.some(e => fs.existsSync(`${e.installPath}/skills/ponytail/SKILL.md`)) ? 0 : 1);
NODE
}
if pony_installed >> "$LOG_FILE" 2>&1; then
  status READY 'Ponytail skill/plugin'
else
  run 'Inspect plugin marketplaces' omp plugin marketplace list
  omp plugin marketplace list > "$WORK_DIR/marketplaces.txt"
  if ! node -e 'const fs = require("node:fs"); process.exit(/^\s*ponytail\s+DietrichGebert\/ponytail\s*$/m.test(fs.readFileSync(process.argv[1], "utf8")) ? 0 : 1)' "$WORK_DIR/marketplaces.txt"; then
    run 'Register official Ponytail marketplace' omp plugin marketplace add DietrichGebert/ponytail
  fi
  run 'Install Ponytail plugin' omp plugin install ponytail@ponytail --scope user --force
  run 'Verify installed Ponytail skill' pony_installed
fi

stage 4 'Prepare browser and documentation tools'
MCP_DIR="$PREFIX/lib/node_modules/@playwright/mcp"
if [[ -f "$MCP_DIR/package.json" ]] && node -e 'process.exit(require(process.argv[1]).version === "0.0.83" ? 0 : 1)' "$MCP_DIR/package.json"; then
  status READY 'Playwright MCP 0.0.83'
else
  run 'Install Playwright MCP' npm install --global --prefix "$PREFIX" --no-fund --no-audit '@playwright/mcp@0.0.83'
fi
run 'Verify Playwright MCP CLI' "$PREFIX/bin/playwright-mcp" --version
PLAYWRIGHT_PACKAGE="$(node -e 'console.log(require.resolve("playwright/package.json", { paths: [process.argv[1]] }))' "$MCP_DIR")"
run 'Install managed Chromium' node "$(dirname "$PLAYWRIGHT_PACKAGE")/cli.js" install chromium
# Keep the existing harness's unsandboxed browser behavior explicit, not hidden.
status NOTICE 'Chromium sandbox is disabled in this harness; use trusted test content only.'
run 'Launch Chromium and check rendered content' node - "$PLAYWRIGHT_PACKAGE" <<'NODE'
const { chromium } = require(require('node:path').dirname(process.argv[2]));
(async () => {
  const browser = await chromium.launch({ headless: true, channel: 'chromium', chromiumSandbox: false });
  try {
    const page = await browser.newPage();
    await page.setContent('<title>OMP browser check</title><main>Browser ready</main>');
    if (await page.title() !== 'OMP browser check' || await page.locator('main').textContent() !== 'Browser ready')
      throw new Error('Chromium did not render the expected content');
    console.log('Chromium rendered and read the expected page.');
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
NODE
run 'Connect to Context7 MCP' curl -fsS --connect-timeout 10 --max-time 30 \
  https://mcp.context7.com/mcp -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  --data '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"omp-installer","version":"1.0.0"}}}' \
  -o "$WORK_DIR/context7.txt"
run 'Verify Context7 protocol response' node - "$WORK_DIR/context7.txt" <<'NODE'
const text = require('node:fs').readFileSync(process.argv[2], 'utf8');
const messages = text.trim().startsWith('{') ? [text] : text.split(/\r?\n/).filter(line => line.startsWith('data:')).map(line => line.slice(5).trim());
if (!messages.some(message => {
  const response = JSON.parse(message);
  return response.id === 1 && response.result?.serverInfo?.name === 'Context7' && response.result?.capabilities?.tools;
})) throw new Error('Context7 did not return a successful MCP initialization');
NODE

link_config() {
  local name="$1" source_path="$OMP_DIR/$1" destination="$CONFIG_DIR/$1"
  local backup count
  if [[ -L "$destination" && "$(readlink "$destination")" == "$source_path" ]]; then
    status READY "$name (current link)"
    return
  fi
  if [[ -e "$destination" || -L "$destination" ]]; then
    backup="$destination.backup.$STAMP"
    count=1
    while [[ -e "$backup" || -L "$backup" ]]; do
      backup="$destination.backup.$STAMP.$count"
      ((count += 1))
    done
    mv "$destination" "$backup"
    status BACKUP "$backup"
  fi
  ln -s "$source_path" "$destination"
  status LINKED "$name"
}

stage 5 'Replace configuration'
for item in config.yml mcp.json agents commands RULES.md templates; do
  link_config "$item"
done
for item in skills extensions; do
  if [[ -e "$OMP_DIR/$item" ]]; then
    link_config "$item"
  fi
done
printf '\n%sInstallation complete%s\n' "$BOLD" "$RESET"
printf '  Start a new OMP session to load the agents, commands and Ponytail.\n'
printf '  Keep this directory first on PATH: %s/bin\n' "$PREFIX"
printf '  Shell setup (if needed): export PATH=%q/bin:"$PATH"\n' "$PREFIX"
printf '  Begin with: /work-new <your request>\n  Full log: %s\n\n' "$LOG_FILE"
