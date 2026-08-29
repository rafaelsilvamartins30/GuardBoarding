#!/usr/bin/env bash

set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../quality-check.sh
source "$REPOSITORY_ROOT/quality-check.sh"

assert_contains() {
  local actual="$1"
  local expected="$2"
  [[ "$actual" == *"$expected"* ]] || {
    printf 'Expected output to contain: %s\nActual output:\n%s\n' "$expected" "$actual" >&2
    exit 1
  }
}

TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf -- "$TEMP_ROOT"' EXIT

cat > "$TEMP_ROOT/pmd.xml" <<'XML'
<pmd>
<file name="src/main/java/example/UserService.java">
<violation beginline="84" rule="CognitiveComplexity" priority="3">
The method has a cognitive complexity of 18.
</violation>
</file>
</pmd>
XML

cat > "$TEMP_ROOT/spotbugs.xml" <<'XML'
<BugCollection>
<BugInstance type="NP_NULL_ON_SOME_PATH" priority="1">
<SourceLine primary="true" sourcepath="example/UserService.java" start="42"/>
<LongMessage>Possible null pointer dereference.</LongMessage>
</BugInstance>
</BugCollection>
XML

pmd_result="$(parse_pmd_xml "$TEMP_ROOT/pmd.xml")"
spotbugs_result="$(parse_spotbugs_xml "$TEMP_ROOT/spotbugs.xml")"

assert_contains "$pmd_result" $'UserService.java\t84\tCognitiveComplexity\tP3'
assert_contains "$spotbugs_result" $'UserService.java\t42\tNP_NULL_ON_SOME_PATH\tP1'
assert_contains "$(guidance_for pmd CognitiveComplexity)" 'smaller steps'
assert_contains "$(guidance_for spotbugs NP_NULL_ON_SOME_PATH)" 'null paths'
assert_contains "$(guidance_for spotbugs UNKNOWN_PATTERN)" 'hypothesis'

RAW_DIR="$TEMP_ROOT/raw"
REPORT="$TEMP_ROOT/report.md"
mkdir -p "$RAW_DIR"
cp "$TEMP_ROOT/pmd.xml" "$RAW_DIR/pmd.xml"
cp "$TEMP_ROOT/spotbugs.xml" "$RAW_DIR/spotbugs.xml"
: > "$REPORT"
append_machine_findings pmd
append_machine_findings spotbugs
report_result="$(cat "$REPORT")"
assert_contains "$report_result" '`pmd:CognitiveComplexity`'
assert_contains "$report_result" '`spotbugs:NP_NULL_ON_SOME_PATH`'
assert_contains "$report_result" 'A warning is not a diagnosis'

LANGUAGE='pt'
assert_contains "$(guidance_for pmd GodClass)" 'responsabilidades'
assert_contains "$(guidance_for pmd UnknownRule)" 'contexto do projeto'

# Test ONLY_CHECKS filtering
ONLY_CHECKS='formatting,security'
assert_contains "$(is_check_enabled formatting && echo 'yes' || echo 'no')" 'yes'
assert_contains "$(is_check_enabled security && echo 'yes' || echo 'no')" 'yes'
assert_contains "$(is_check_enabled pmd && echo 'yes' || echo 'no')" 'no'
ONLY_CHECKS=''
assert_contains "$(is_check_enabled pmd && echo 'yes' || echo 'no')" 'yes'

# Test init setup in temporary folder
INIT_DIR="$TEMP_ROOT/init_test"
INIT_TARGET="$INIT_DIR"
init_output="$(do_init_setup)"
assert_contains "$init_output" 'GuardBoarding Setup'
assert_contains "$init_output" 'WIP'
[[ -f "$INIT_DIR/config/checkstyle/checkstyle.xml" ]] || { echo "Init failed to create checkstyle.xml" >&2; exit 1; }
[[ -f "$INIT_DIR/config/pmd/ruleset.xml" ]] || { echo "Init failed to create ruleset.xml" >&2; exit 1; }
[[ -f "$INIT_DIR/docs/ARCHITECTURE.md" ]] || { echo "Init failed to create ARCHITECTURE.md" >&2; exit 1; }
[[ -f "$INIT_DIR/quality-check.sh" ]] || { echo "Init failed to create quality-check.sh" >&2; exit 1; }

printf 'quality-check tests passed\n'

