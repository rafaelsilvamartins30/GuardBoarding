#!/usr/bin/env bash

# GuardBoarding quality-check.sh
# Adaptable example for Java/Maven projects. English output is the default.

set -uo pipefail

LANGUAGE='en'
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
LAST_RUN="${PROJECT_ROOT}/.quality/last-run"
RAW_DIR="${LAST_RUN}/raw"
SUMMARY="${LAST_RUN}/summary.txt"
REPORT="${LAST_RUN}/report.md"
PASSED=0
FAILED=0
SKIPPED=0

usage() {
  cat <<'EOF'
Usage: ./quality-check.sh [--lang en|pt] [--help]

Options:
  --lang en|pt  Report language. English is the default.
  --help        Show this help message.
EOF
}

parse_arguments() {
  while (( $# > 0 )); do
    case "$1" in
      --lang)
        [[ $# -ge 2 ]] || { echo 'Missing value for --lang.' >&2; exit 2; }
        LANGUAGE="$2"
        shift 2
        ;;
      --help|-h) usage; exit 0 ;;
      *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
  done
  [[ "$LANGUAGE" == 'en' || "$LANGUAGE" == 'pt' ]] || {
    echo "Unsupported language: $LANGUAGE (use en or pt)." >&2
    exit 2
  }
}

msg() {
  local key="$1"
  if [[ "$LANGUAGE" == 'pt' ]]; then
    case "$key" in
      unexpected_path) echo 'Caminho de saída inesperado' ;;
      title) echo 'GuardBoarding — última execução' ;;
      generated) echo 'Gerado em' ;;
      original) echo 'Resultado original' ;;
      excerpt) echo 'Trecho relevante da saída' ;;
      findings) echo 'Achados do relatório da ferramenta' ;;
      not_run) echo 'Não executado' ;;
      missing) echo 'Ausente ou vazio' ;;
      missing_dir) echo 'Diretório ausente' ;;
      report) echo 'Relatório' ;;
      totals) echo 'Aprovadas: %s | Falhas: %s | Ignoradas: %s' ;;
      no_maven) echo 'Maven Wrapper e Maven não foram encontrados.' ;;
      no_gitleaks) echo 'Gitleaks não está instalado.' ;;
      formatting) echo 'Formatação' ;;
      conventions) echo 'Convenções' ;;
      pmd) echo 'Análise PMD' ;;
      spotbugs) echo 'Possíveis bugs' ;;
      architecture) echo 'Arquitetura' ;;
      tests) echo 'Testes' ;;
      coverage) echo 'Cobertura' ;;
      security) echo 'Secrets' ;;
      documentation) echo 'Documentação essencial' ;;
    esac
  else
    case "$key" in
      unexpected_path) echo 'Unexpected output path' ;;
      title) echo 'GuardBoarding — last run' ;;
      generated) echo 'Generated at' ;;
      original) echo 'Original output' ;;
      excerpt) echo 'Relevant output excerpt' ;;
      findings) echo 'Findings from the tool report' ;;
      not_run) echo 'Not run' ;;
      missing) echo 'Missing or empty' ;;
      missing_dir) echo 'Missing directory' ;;
      report) echo 'Report' ;;
      totals) echo 'Passed: %s | Failed: %s | Skipped: %s' ;;
      no_maven) echo 'Neither Maven Wrapper nor Maven was found.' ;;
      no_gitleaks) echo 'Gitleaks is not installed.' ;;
      formatting) echo 'Formatting' ;;
      conventions) echo 'Conventions' ;;
      pmd) echo 'PMD analysis' ;;
      spotbugs) echo 'Possible bugs' ;;
      architecture) echo 'Architecture' ;;
      tests) echo 'Tests' ;;
      coverage) echo 'Coverage' ;;
      security) echo 'Secrets' ;;
      documentation) echo 'Essential documentation' ;;
    esac
  fi
}

explanation_for() {
  local id="$1"
  if [[ "$LANGUAGE" == 'pt' ]]; then
    case "$id" in
      formatting) echo 'Mantém diffs focados no conteúdo, não em preferências visuais.' ;;
      conventions) echo 'Torna nomes e estruturas previsíveis para quem navega no projeto.' ;;
      pmd) echo 'Sinaliza estruturas que podem concentrar complexidade ou responsabilidades.' ;;
      spotbugs) echo 'Procura padrões de bytecode associados a possíveis defeitos.' ;;
      architecture) echo 'Confere se as dependências seguem a arquitetura decidida.' ;;
      tests) echo 'Verifica se os comportamentos cobertos continuam funcionando.' ;;
      coverage) echo 'Mostra o que foi exercitado; cobertura não prova qualidade sozinha.' ;;
      security) echo 'Ajuda a impedir que possíveis secrets permaneçam no histórico Git.' ;;
      documentation) echo 'Mantém instalação, contribuição, arquitetura e decisões acessíveis.' ;;
      *) echo 'Consulte a saída original para interpretar esta verificação.' ;;
    esac
  else
    case "$id" in
      formatting) echo 'Keeps diffs focused on content instead of visual preferences.' ;;
      conventions) echo 'Makes names and structures predictable for project navigation.' ;;
      pmd) echo 'Flags structures that may concentrate complexity or responsibilities.' ;;
      spotbugs) echo 'Looks for bytecode patterns associated with possible defects.' ;;
      architecture) echo 'Checks whether dependencies follow the chosen architecture.' ;;
      tests) echo 'Checks whether covered behavior continues to work.' ;;
      coverage) echo 'Shows what was exercised; coverage alone does not prove quality.' ;;
      security) echo 'Helps prevent possible secrets from remaining in Git history.' ;;
      documentation) echo 'Keeps setup, contribution, architecture, and decisions accessible.' ;;
      *) echo 'Read the original output to interpret this check.' ;;
    esac
  fi
}

prepare_output() {
  case "$LAST_RUN" in
    */.quality/last-run) ;;
    *) printf '%s: %s\n' "$(msg unexpected_path)" "$LAST_RUN" >&2; exit 2 ;;
  esac
  rm -rf -- "$LAST_RUN"
  mkdir -p "$RAW_DIR"
  : > "$SUMMARY"
  printf '# %s\n\n' "$(msg title)" > "$REPORT"
  printf '%s: %s\n\n' "$(msg generated)" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$REPORT"
}

strip_ansi() {
  sed $'s/\033\[[0-9;]*[[:alpha:]]//g' "$1"
}

failure_excerpt() {
  local id="$1"
  local log_file="$2"
  local excerpt=''
  case "$id" in
    pmd)
      excerpt="$(strip_ansi "$log_file" | grep -E 'PMD Failure|[[:alnum:]_./-]+\.java:[0-9]+' | head -20 || true)"
      ;;
    spotbugs)
      excerpt="$(strip_ansi "$log_file" | grep -E '(High|Medium|Low):|At .*\[line|\[[A-Z][A-Z0-9_]+\]' | head -20 || true)"
      ;;
    *) excerpt="$(strip_ansi "$log_file" | tail -12)" ;;
  esac
  [[ -n "$excerpt" ]] || excerpt="$(strip_ansi "$log_file" | tail -12)"
  printf '%s' "$excerpt"
}

preserve_machine_report() {
  local id="$1"
  local marker="$2"
  local candidate=''
  case "$id" in
    pmd) candidate="$(find "$PROJECT_ROOT" -path '*/target/pmd.xml' -type f -newer "$marker" -print -quit 2>/dev/null || true)" ;;
    spotbugs) candidate="$(find "$PROJECT_ROOT" \( -path '*/target/spotbugsXml.xml' -o -path '*/target/spotbugs.xml' \) -type f -newer "$marker" -print -quit 2>/dev/null || true)" ;;
  esac
  [[ -z "$candidate" ]] || cp "$candidate" "$RAW_DIR/${id}.xml"
}

parse_pmd_xml() {
  awk '
    function attribute(text, key, value) {
      value = text
      if (value !~ (key "=\"")) return ""
      sub(".*" key "=\"", "", value)
      sub("\".*", "", value)
      return value
    }
    function clean(text) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", text)
      gsub(/&quot;/, "\"", text); gsub(/&apos;/, "\047", text)
      gsub(/&lt;/, "<", text); gsub(/&gt;/, ">", text); gsub(/&amp;/, "\\&", text)
      return text
    }
    /<file name=/ { file = attribute($0, "name") }
    /<violation / {
      line = attribute($0, "beginline"); rule = attribute($0, "rule")
      priority = attribute($0, "priority"); message = ""; inside = 1; next
    }
    /<\/violation>/ {
      if (inside && shown < 20) {
        printf "%s:%s | %s | P%s | %s\n", file, line, rule, priority, clean(message)
        shown++
      }
      inside = 0; next
    }
    inside { message = message " " clean($0) }
  ' "$1"
}

parse_spotbugs_xml() {
  sed 's/></>\n</g' "$1" | awk '
    function attribute(text, key, value) {
      value = text
      if (value ~ (key "=\"")) {
        sub(".*" key "=\"", "", value)
        sub("\".*", "", value)
        return value
      }
      value = text
      if (value !~ (key "=\047")) return ""
      sub(".*" key "=\047", "", value)
      sub("\047.*", "", value)
      return value
    }
    function clean(text) {
      gsub(/<[^>]+>/, "", text); gsub(/^[[:space:]]+|[[:space:]]+$/, "", text)
      gsub(/&quot;/, "\"", text); gsub(/&apos;/, "\047", text)
      gsub(/&lt;/, "<", text); gsub(/&gt;/, ">", text); gsub(/&amp;/, "\\&", text)
      return text
    }
    /<file / { current_class = attribute($0, "classname") }
    /<BugInstance / {
      type = attribute($0, "type"); priority = attribute($0, "priority")
      file = current_class; line = attribute($0, "lineNumber")
      message = attribute($0, "message"); inside = 1
      if ($0 ~ /\/>/) print_finding()
    }
    inside && /<SourceLine / && (file == "" || attribute($0, "primary") == "true") {
      file = attribute($0, "sourcepath"); line = attribute($0, "start")
    }
    inside && /<LongMessage>/ { message = clean($0) }
    function print_finding() {
      if (inside && shown < 20) {
        if (file == "") file = "unknown"
        if (line == "") line = "?"
        if (message == "") message = type
        printf "%s:%s | %s | priority %s | %s\n", file, line, type, priority, clean(message)
        shown++
      }
      inside = 0
    }
    /<\/BugInstance>/ { print_finding() }
  '
}

append_machine_findings() {
  local id="$1"
  local xml_file="${RAW_DIR}/${id}.xml"
  [[ -s "$xml_file" ]] || return
  local findings=''
  case "$id" in
    pmd) findings="$(parse_pmd_xml "$xml_file")" ;;
    spotbugs) findings="$(parse_spotbugs_xml "$xml_file")" ;;
  esac
  [[ -n "$findings" ]] || return
  printf '**%s**\n\n```text\n%s\n```\n\n' "$(msg findings)" "$findings" >> "$REPORT"
}

run_check() {
  local id="$1"
  local label="$2"
  shift 2
  local log_file="${RAW_DIR}/${id}.log"
  local marker="${RAW_DIR}/.${id}.started"
  touch "$marker"
  printf '→ %s\n' "$label"
  if "$@" > "$log_file" 2>&1; then
    printf 'PASS | %s\n' "$label" >> "$SUMMARY"
    printf '## ✓ %s\n\n%s\n\n' "$label" "$(explanation_for "$id")" >> "$REPORT"
    PASSED=$((PASSED + 1))
  else
    local status=$?
    printf 'FAIL | %s | raw/%s.log\n' "$label" "$id" >> "$SUMMARY"
    printf '## ✗ %s\n\n%s\n\n' "$label" "$(explanation_for "$id")" >> "$REPORT"
    printf '%s: `raw/%s.log` (exit %s)\n\n' "$(msg original)" "$id" "$status" >> "$REPORT"
    printf '**%s**\n\n```text\n%s\n```\n\n' "$(msg excerpt)" "$(failure_excerpt "$id" "$log_file")" >> "$REPORT"
    FAILED=$((FAILED + 1))
  fi
  preserve_machine_report "$id" "$marker"
  append_machine_findings "$id"
  rm -f -- "$marker"
}

skip_check() {
  local label="$1"
  local reason="$2"
  printf 'SKIP | %s | %s\n' "$label" "$reason" >> "$SUMMARY"
  printf '## – %s\n\n%s: %s\n\n' "$label" "$(msg not_run)" "$reason" >> "$REPORT"
  SKIPPED=$((SKIPPED + 1))
}

check_documentation() {
  local missing=0
  for file in README.md docs/ARCHITECTURE.md docs/CONTRIBUTING.md; do
    if [[ ! -s "$PROJECT_ROOT/$file" ]]; then
      printf '%s: %s\n' "$(msg missing)" "$file"
      missing=1
    fi
  done
  [[ -d "$PROJECT_ROOT/docs/adr" ]] || { printf '%s: docs/adr\n' "$(msg missing_dir)"; missing=1; }
  return "$missing"
}

run_maven_checks() {
  local maven=''
  if [[ -x './mvnw' ]]; then
    maven='./mvnw'
  elif command -v mvn >/dev/null 2>&1; then
    maven='mvn'
  else
    local reason="$(msg no_maven)"
    for id in formatting conventions pmd spotbugs architecture tests coverage; do
      skip_check "$(msg "$id")" "$reason"
    done
    return
  fi

  run_check formatting "$(msg formatting)" "$maven" -q spotless:check
  run_check conventions "$(msg conventions)" "$maven" -q checkstyle:check
  run_check pmd "$(msg pmd)" "$maven" -q -Dpmd.printFailingErrors=true -Dpmd.verbose=true pmd:check
  run_check spotbugs "$(msg spotbugs)" "$maven" -q -Dspotbugs.xmlOutput=true -Dspotbugs.quiet=false spotbugs:check
  run_check architecture "$(msg architecture)" "$maven" -q -Dtest=ArchitectureTest test
  run_check tests "$(msg tests)" "$maven" -q test
  run_check coverage "$(msg coverage)" "$maven" -q jacoco:report
}

main() {
  parse_arguments "$@"
  cd "$PROJECT_ROOT" || exit 2
  prepare_output
  run_maven_checks

  if command -v gitleaks >/dev/null 2>&1; then
    run_check security "$(msg security)" gitleaks git --redact --no-banner
  else
    skip_check "$(msg security)" "$(msg no_gitleaks)"
  fi
  run_check documentation "$(msg documentation)" check_documentation

  local totals
  printf -v totals "$(msg totals)" "$PASSED" "$FAILED" "$SKIPPED"
  printf '\n%s\n' "$totals" | tee -a "$SUMMARY"
  printf '\n%s: %s\n' "$(msg report)" "$REPORT"
  (( FAILED == 0 ))
}

main "$@"
