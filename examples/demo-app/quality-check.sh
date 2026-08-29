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
AUTO_FIX=0
ONLY_CHECKS=''
OPT_NO_COLOR=0
DO_INIT=0
INIT_TARGET=''

C_RESET=''
C_BOLD=''
C_GREEN=''
C_RED=''
C_YELLOW=''
C_BLUE=''
C_CYAN=''
C_DIM=''

# Colors
setup_colors() {
  if [[ -t 1 && -z "${NO_COLOR:-}" && "$OPT_NO_COLOR" -eq 0 ]]; then
    C_RESET=$'\033[0m'
    C_BOLD=$'\033[1m'
    C_GREEN=$'\033[32m'
    C_RED=$'\033[31m'
    C_YELLOW=$'\033[33m'
    C_BLUE=$'\033[34m'
    C_CYAN=$'\033[36m'
    C_DIM=$'\033[2m'
  else
    C_RESET=''
    C_BOLD=''
    C_GREEN=''
    C_RED=''
    C_YELLOW=''
    C_BLUE=''
    C_CYAN=''
    C_DIM=''
  fi
}

usage() {
  cat <<'EOF'
Usage: ./quality-check.sh [OPTIONS]

Options:
  --lang en|pt       Report and CLI language. English is the default.
  --fix              Automatically apply safe formatting before checks (Spotless).
  --only <checks>    Comma-separated list of checks to run (e.g. formatting,conventions,security).
  --no-color         Disable colorized terminal output.
  --init [dir]       Initialize GuardBoarding in a target project (Experimental / WIP).
  --help, -h         Show this help message.
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
      --fix)
        AUTO_FIX=1
        shift
        ;;
      --only)
        [[ $# -ge 2 ]] || { echo 'Missing value for --only.' >&2; exit 2; }
        ONLY_CHECKS="$2"
        shift 2
        ;;
      --no-color)
        OPT_NO_COLOR=1
        shift
        ;;
      --init)
        DO_INIT=1
        if [[ $# -ge 2 && ! "$2" =~ ^-- ]]; then
          INIT_TARGET="$2"
          shift 2
        else
          INIT_TARGET="."
          shift 1
        fi
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

is_check_enabled() {
  local check_id="$1"
  if [[ -z "$ONLY_CHECKS" ]]; then
    return 0
  fi
  local IFS=','
  for item in $ONLY_CHECKS; do
    if [[ "$item" == "$check_id" ]]; then
      return 0
    fi
  done
  return 1
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
      guidance) echo 'Orientação para revisão' ;;
      false_positive) echo 'Alerta não é diagnóstico: confirme o contexto antes de corrigir ou suprimir.' ;;
      not_run) echo 'Não executado' ;;
      missing) echo 'Ausente ou vazio' ;;
      missing_dir) echo 'Diretório ausente' ;;
      report) echo 'Relatório' ;;
      totals) echo 'Aprovadas: %s | Falhas: %s | Ignoradas: %s' ;;
      no_maven) echo 'Maven Wrapper e Maven não foram encontrados.' ;;
      no_pom) echo 'pom.xml não foi encontrado na raiz do projeto.' ;;
      no_gitleaks) echo 'Gitleaks não está instalado.' ;;
      no_git) echo 'Repositório Git não detectado.' ;;
      sensitive_found) echo 'Arquivos potencialmente sensíveis rastreados no Git' ;;
      formatting) echo 'Formatação' ;;
      conventions) echo 'Convenções' ;;
      pmd) echo 'Análise PMD' ;;
      spotbugs) echo 'Possíveis bugs' ;;
      architecture) echo 'Arquitetura' ;;
      tests) echo 'Testes' ;;
      coverage) echo 'Cobertura' ;;
      security) echo 'Secrets' ;;
      sensitive_files) echo 'Arquivos sensíveis' ;;
      documentation) echo 'Documentação essencial' ;;
      init_header) echo 'GuardBoarding Setup' ;;
      init_wip) echo 'AVISO: Este instalador está em desenvolvimento (Experimental / WIP).' ;;
      init_dest) echo 'Diretório de destino:' ;;
      init_success) echo 'GuardBoarding inicializado com sucesso em:' ;;
      init_next) echo 'Próximos passos:' ;;
    esac
  else
    case "$key" in
      unexpected_path) echo 'Unexpected output path' ;;
      title) echo 'GuardBoarding — last run' ;;
      generated) echo 'Generated at' ;;
      original) echo 'Original output' ;;
      excerpt) echo 'Relevant output excerpt' ;;
      findings) echo 'Findings from the tool report' ;;
      guidance) echo 'Review guidance' ;;
      false_positive) echo 'A warning is not a diagnosis: confirm the context before fixing or suppressing it.' ;;
      not_run) echo 'Not run' ;;
      missing) echo 'Missing or empty' ;;
      missing_dir) echo 'Missing directory' ;;
      report) echo 'Report' ;;
      totals) echo 'Passed: %s | Failed: %s | Skipped: %s' ;;
      no_maven) echo 'Neither Maven Wrapper nor Maven was found.' ;;
      no_pom) echo 'pom.xml was not found in the project root.' ;;
      no_gitleaks) echo 'Gitleaks is not installed.' ;;
      no_git) echo 'Git repository was not detected.' ;;
      sensitive_found) echo 'Potentially sensitive files tracked in Git' ;;
      formatting) echo 'Formatting' ;;
      conventions) echo 'Conventions' ;;
      pmd) echo 'PMD analysis' ;;
      spotbugs) echo 'Possible bugs' ;;
      architecture) echo 'Architecture' ;;
      tests) echo 'Tests' ;;
      coverage) echo 'Coverage' ;;
      security) echo 'Secrets' ;;
      sensitive_files) echo 'Sensitive files' ;;
      documentation) echo 'Essential documentation' ;;
      init_header) echo 'GuardBoarding Setup' ;;
      init_wip) echo 'WARNING: This setup wizard is under active development (Experimental / WIP).' ;;
      init_dest) echo 'Destination directory:' ;;
      init_success) echo 'GuardBoarding successfully initialized in:' ;;
      init_next) echo 'Next steps:' ;;
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
      sensitive_files) echo 'Garante que credenciais locais, chaves e arquivos de ambiente não sejam rastreados no Git.' ;;
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
      sensitive_files) echo 'Ensures local credentials, keys, and environment files are not tracked in Git.' ;;
      documentation) echo 'Keeps setup, contribution, architecture, and decisions accessible.' ;;
      *) echo 'Read the original output to interpret this check.' ;;
    esac
  fi
}

guidance_for() {
  local tool="$1"
  local rule="$2"
  if [[ "$LANGUAGE" == 'pt' ]]; then
    case "$tool:$rule" in
      pmd:CognitiveComplexity|pmd:CyclomaticComplexity) echo 'Confira se o fluxo pode ser dividido em passos menores sem esconder a regra de negócio.' ;;
      pmd:GodClass) echo 'Confira se a classe concentra responsabilidades que mudam por motivos diferentes.' ;;
      spotbugs:NP_*) echo 'Confira caminhos nulos, contratos de retorno e validações existentes.' ;;
      spotbugs:EI_*|spotbugs:MS_*) echo 'Confira se estado mutável é exposto e se uma cópia defensiva é necessária.' ;;
      spotbugs:*) echo 'Trate o padrão de bytecode como hipótese e confirme fluxo, contratos e testes.' ;;
      pmd:*) echo 'Leia a regra no contexto do projeto e confirme se o padrão representa um problema real.' ;;
      *) echo 'Consulte a regra e a evidência original antes de decidir qualquer alteração.' ;;
    esac
  else
    case "$tool:$rule" in
      pmd:CognitiveComplexity|pmd:CyclomaticComplexity) echo 'Check whether the flow can be split into smaller steps without hiding the business rule.' ;;
      pmd:GodClass) echo 'Check whether the class concentrates responsibilities that change for different reasons.' ;;
      spotbugs:NP_*) echo 'Check null paths, return contracts, and existing validation.' ;;
      spotbugs:EI_*|spotbugs:MS_*) echo 'Check whether mutable state is exposed and whether a defensive copy is needed.' ;;
      spotbugs:*) echo 'Treat the bytecode pattern as a hypothesis and confirm flow, contracts, and tests.' ;;
      pmd:*) echo 'Read the rule in project context and confirm whether the pattern is a real problem.' ;;
      *) echo 'Read the rule and original evidence before deciding on any change.' ;;
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
        printf "%s\t%s\t%s\t%s\t%s\n", file, line, rule, "P" priority, clean(message)
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
        printf "%s\t%s\t%s\t%s\t%s\n", file, line, type, "P" priority, clean(message)
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
  printf '**%s**\n\n' "$(msg findings)" >> "$REPORT"
  while IFS=$'\t' read -r file line rule priority message; do
    printf -- '- `%s:%s` | `%s:%s` | %s | %s\n' "$file" "$line" "$id" "$rule" "$priority" "$message" >> "$REPORT"
    printf '  - **%s:** %s\n' "$(msg guidance)" "$(guidance_for "$id" "$rule")" >> "$REPORT"
  done <<< "$findings"
  printf '\n> %s\n\n' "$(msg false_positive)" >> "$REPORT"
}

run_check() {
  local id="$1"
  local label="$2"
  shift 2

  if ! is_check_enabled "$id"; then
    return 0
  fi

  local log_file="${RAW_DIR}/${id}.log"
  local marker="${RAW_DIR}/.${id}.started"
  touch "$marker"

  if "$@" > "$log_file" 2>&1; then
    printf 'PASS | %s\n' "$label" >> "$SUMMARY"
    printf '## ✓ %s\n\n%s\n\n' "$label" "$(explanation_for "$id")" >> "$REPORT"
    printf '  %s✓ PASS%s  %s\n' "$C_GREEN$C_BOLD" "$C_RESET" "$label"
    PASSED=$((PASSED + 1))
  else
    local status=$?
    printf 'FAIL | %s | raw/%s.log\n' "$label" "$id" >> "$SUMMARY"
    printf '## ✗ %s\n\n%s\n\n' "$label" "$(explanation_for "$id")" >> "$REPORT"
    printf '%s: `raw/%s.log` (exit %s)\n\n' "$(msg original)" "$id" "$status" >> "$REPORT"
    printf '**%s**\n\n```text\n%s\n```\n\n' "$(msg excerpt)" "$(failure_excerpt "$id" "$log_file")" >> "$REPORT"
    printf '  %s✗ FAIL%s  %s%s%s %s(raw/%s.log)%s\n' "$C_RED$C_BOLD" "$C_RESET" "$C_BOLD" "$label" "$C_RESET" "$C_DIM" "$id" "$C_RESET"
    FAILED=$((FAILED + 1))
  fi
  preserve_machine_report "$id" "$marker"
  append_machine_findings "$id"
  rm -f -- "$marker"
}

skip_check() {
  local id="$1"
  local label="$2"
  local reason="$3"

  if ! is_check_enabled "$id"; then
    return 0
  fi

  printf 'SKIP | %s | %s\n' "$label" "$reason" >> "$SUMMARY"
  printf '## – %s\n\n%s: %s\n\n' "$label" "$(msg not_run)" "$reason" >> "$REPORT"
  printf '  %s– SKIP%s  %s %s(%s)%s\n' "$C_YELLOW$C_BOLD" "$C_RESET" "$label" "$C_DIM" "$reason" "$C_RESET"
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

check_sensitive_files() {
  if ! command -v git >/dev/null 2>&1 || ! git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  local tracked_sensitive
  tracked_sensitive="$(git -C "$PROJECT_ROOT" ls-files | grep -Ei '(\.env($|\..+)|(\.pem|\.key|\.p12|\.keystore|id_rsa|id_dsa|id_ed25519)$|credentials\.json$)' | grep -vEi '\.example$|\.sample$|\.template$' || true)"

  if [[ -n "$tracked_sensitive" ]]; then
    printf '%s:\n%s\n' "$(msg sensitive_found)" "$tracked_sensitive"
    return 1
  fi
  return 0
}

run_maven_checks() {
  if [[ ! -f "$PROJECT_ROOT/pom.xml" ]]; then
    local reason="$(msg no_pom)"
    for id in formatting conventions pmd spotbugs architecture tests coverage; do
      skip_check "$id" "$(msg "$id")" "$reason"
    done
    return
  fi

  local maven=''
  if [[ -x "$PROJECT_ROOT/mvnw" ]]; then
    maven="$PROJECT_ROOT/mvnw"
  elif [[ -x './mvnw' ]]; then
    maven='./mvnw'
  elif command -v mvn >/dev/null 2>&1; then
    maven='mvn'
  else
    local reason="$(msg no_maven)"
    for id in formatting conventions pmd spotbugs architecture tests coverage; do
      skip_check "$id" "$(msg "$id")" "$reason"
    done
    return
  fi

  if (( AUTO_FIX == 1 )) && is_check_enabled formatting; then
    "$maven" -q spotless:apply >/dev/null 2>&1 || true
  fi

  run_check formatting "$(msg formatting)" "$maven" -q spotless:check
  run_check conventions "$(msg conventions)" "$maven" -q checkstyle:check
  run_check pmd "$(msg pmd)" "$maven" -q -Dpmd.printFailingErrors=true -Dpmd.verbose=true pmd:check
  run_check spotbugs "$(msg spotbugs)" "$maven" -q -Dspotbugs.xmlOutput=true -Dspotbugs.quiet=false spotbugs:check
  run_check architecture "$(msg architecture)" "$maven" -q -Dtest=ArchitectureTest test
  run_check tests "$(msg tests)" "$maven" -q test
  run_check coverage "$(msg coverage)" "$maven" -q jacoco:report
}

do_init_setup() {
  local target_dir="${INIT_TARGET:-.}"
  local script_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local resolved_target
  mkdir -p "$target_dir"
  resolved_target="$(cd "$target_dir" && pwd)"

  printf '\n%s%s======================================================================%s\n' "$C_YELLOW" "$C_BOLD" "$C_RESET"
  printf '%s%s⚠️  %s%s\n' "$C_YELLOW" "$C_BOLD" "$(msg init_header)" "$C_RESET"
  printf '%s%s%s\n' "$C_YELLOW" "$(msg init_wip)" "$C_RESET"
  printf '%s%s======================================================================%s\n\n' "$C_YELLOW" "$C_BOLD" "$C_RESET"

  printf '%s %s%s%s\n\n' "$(msg init_dest)" "$C_CYAN" "$resolved_target" "$C_RESET"

  mkdir -p "$resolved_target/config/checkstyle"
  mkdir -p "$resolved_target/config/pmd"
  mkdir -p "$resolved_target/config/spotbugs"
  mkdir -p "$resolved_target/docs/adr"
  mkdir -p "$resolved_target/docs/pt-BR/adr"

  local copied_count=0
  copy_if_missing() {
    local src="$1"
    local dest="$2"
    if [[ ! -f "$dest" && -f "$src" ]]; then
      cp "$src" "$dest"
      printf '  %s+ Created:%s %s\n' "$C_GREEN" "$C_RESET" "${dest#$resolved_target/}"
      copied_count=$((copied_count + 1))
    fi
  }

  copy_if_missing "$script_source_dir/config/checkstyle/checkstyle.xml" "$resolved_target/config/checkstyle/checkstyle.xml"
  copy_if_missing "$script_source_dir/config/pmd/ruleset.xml" "$resolved_target/config/pmd/ruleset.xml"
  copy_if_missing "$script_source_dir/config/spotbugs/exclude.xml" "$resolved_target/config/spotbugs/exclude.xml"
  copy_if_missing "$script_source_dir/docs/ARCHITECTURE.md" "$resolved_target/docs/ARCHITECTURE.md"
  copy_if_missing "$script_source_dir/docs/CONTRIBUTING.md" "$resolved_target/docs/CONTRIBUTING.md"
  copy_if_missing "$script_source_dir/docs/adr/README.md" "$resolved_target/docs/adr/README.md"
  copy_if_missing "$script_source_dir/docs/pt-BR/ARCHITECTURE.md" "$resolved_target/docs/pt-BR/ARCHITECTURE.md"
  copy_if_missing "$script_source_dir/docs/pt-BR/CONTRIBUTING.md" "$resolved_target/docs/pt-BR/CONTRIBUTING.md"
  copy_if_missing "$script_source_dir/docs/pt-BR/adr/README.md" "$resolved_target/docs/pt-BR/adr/README.md"
  copy_if_missing "$script_source_dir/quality-check.sh" "$resolved_target/quality-check.sh"
  copy_if_missing "$script_source_dir/lefthook.yml" "$resolved_target/lefthook.yml"

  if [[ -f "$resolved_target/quality-check.sh" ]]; then
    chmod +x "$resolved_target/quality-check.sh"
  fi

  if [[ -f "$resolved_target/.gitignore" ]]; then
    if ! grep -q '^\.quality' "$resolved_target/.gitignore" 2>/dev/null; then
      printf '\n.quality/\n' >> "$resolved_target/.gitignore"
      printf '  %s+ Added:%s .quality/ to .gitignore\n' "$C_GREEN" "$C_RESET"
    fi
  fi

  printf '\n%s%s%s %s\n' "$C_GREEN$C_BOLD" "$(msg init_success)" "$C_RESET" "$resolved_target"
  printf '\n%s%s%s\n' "$C_BOLD" "$(msg init_next)" "$C_RESET"
  if [[ "$LANGUAGE" == 'pt' ]]; then
    printf '  1. Adicione os plugins necessários ao seu %s/pom.xml%s (veja %sexamples/pom-plugins.xml%s)\n' "$C_CYAN" "$C_RESET" "$C_CYAN" "$C_RESET"
    printf '  2. Documente a arquitetura e diretrizes em %sdocs/ARCHITECTURE.md%s\n' "$C_CYAN" "$C_RESET"
    printf '  3. Execute %s./quality-check.sh%s para validar\n\n' "$C_CYAN" "$C_RESET"
  else
    printf '  1. Add the necessary plugins to your %s/pom.xml%s (see %sexamples/pom-plugins.xml%s)\n' "$C_CYAN" "$C_RESET" "$C_CYAN" "$C_RESET"
    printf '  2. Document the architecture in %sdocs/ARCHITECTURE.md%s\n' "$C_CYAN" "$C_RESET"
    printf '  3. Run %s./quality-check.sh%s to validate\n\n' "$C_CYAN" "$C_RESET"
  fi
}

main() {
  parse_arguments "$@"
  setup_colors

  if (( DO_INIT == 1 )); then
    do_init_setup
    return 0
  fi

  cd "$PROJECT_ROOT" || exit 2
  prepare_output

  printf '\n%s%s▶ %s%s %s(%s)%s\n\n' "$C_CYAN$C_BOLD" "$(msg title)" "$C_RESET" "$C_DIM" "$PROJECT_ROOT" "$C_RESET"

  run_maven_checks

  if is_check_enabled security; then
    if command -v gitleaks >/dev/null 2>&1; then
      run_check security "$(msg security)" gitleaks git --redact --no-banner
    else
      skip_check security "$(msg security)" "$(msg no_gitleaks)"
    fi
  fi

  if is_check_enabled sensitive_files; then
    run_check sensitive_files "$(msg sensitive_files)" check_sensitive_files
  fi

  if is_check_enabled documentation; then
    run_check documentation "$(msg documentation)" check_documentation
  fi

  local totals
  printf -v totals "$(msg totals)" "$PASSED" "$FAILED" "$SKIPPED"
  printf '\n%s\n' "$totals" >> "$SUMMARY"

  printf '\n%s%s──────────────────────────────────────────────────────────────────%s\n' "$C_DIM" "" "$C_RESET"
  if (( FAILED == 0 )); then
    printf '%s%s%s%s\n' "$C_GREEN$C_BOLD" "$totals" "$C_RESET" ""
  else
    printf '%s%s%s%s\n' "$C_RED$C_BOLD" "$totals" "$C_RESET" ""
  fi
  printf '%s: %s%s%s\n\n' "$(msg report)" "$C_CYAN" "$REPORT" "$C_RESET"

  (( FAILED == 0 ))
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
