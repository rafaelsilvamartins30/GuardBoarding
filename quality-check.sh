#!/usr/bin/env bash

# GuardBoarding quality-check.sh
# Exemplo adaptável: execute a partir da raiz de um projeto Java/Maven.

set -uo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
LAST_RUN="${PROJECT_ROOT}/.quality/last-run"
RAW_DIR="${LAST_RUN}/raw"
SUMMARY="${LAST_RUN}/summary.txt"
REPORT="${LAST_RUN}/report.md"
PASSED=0
FAILED=0
SKIPPED=0

prepare_output() {
  case "$LAST_RUN" in
    */.quality/last-run) ;;
    *) echo "Caminho de saída inesperado: $LAST_RUN" >&2; exit 2 ;;
  esac

  rm -rf -- "$LAST_RUN"
  mkdir -p "$RAW_DIR"
  : > "$SUMMARY"
  printf '# GuardBoarding — última execução\n\n' > "$REPORT"
  printf 'Gerado em: %s\n\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$REPORT"
}

explanation_for() {
  case "$1" in
    formatting) echo 'Mantém diffs focados no conteúdo, não em preferências visuais.' ;;
    conventions) echo 'Torna nomes e estruturas previsíveis para quem navega no projeto.' ;;
    pmd) echo 'Sinaliza estruturas que podem concentrar complexidade ou responsabilidades.' ;;
    spotbugs) echo 'Procura padrões de bytecode associados a possíveis defeitos.' ;;
    architecture) echo 'Confere se as dependências continuam seguindo a arquitetura decidida.' ;;
    tests) echo 'Verifica se os comportamentos cobertos continuam funcionando.' ;;
    coverage) echo 'Mostra o que foi exercitado; cobertura não prova qualidade sozinha.' ;;
    security) echo 'Ajuda a impedir que possíveis secrets permaneçam no histórico Git.' ;;
    documentation) echo 'Mantém instalação, contribuição, arquitetura e decisões acessíveis.' ;;
    *) echo 'Consulte a saída original para interpretar esta verificação.' ;;
  esac
}

run_check() {
  local id="$1"
  local label="$2"
  shift 2
  local log_file="${RAW_DIR}/${id}.log"

  printf '→ %s\n' "$label"
  if "$@" > "$log_file" 2>&1; then
    printf 'PASS | %s\n' "$label" >> "$SUMMARY"
    printf '## ✓ %s\n\n%s\n\n' "$label" "$(explanation_for "$id")" >> "$REPORT"
    PASSED=$((PASSED + 1))
  else
    local status=$?
    printf 'FAIL | %s | raw/%s.log\n' "$label" "$id" >> "$SUMMARY"
    printf '## ✗ %s\n\n%s\n\n' "$label" "$(explanation_for "$id")" >> "$REPORT"
    printf 'Resultado original: `raw/%s.log` (exit %s)\n\n' "$id" "$status" >> "$REPORT"
    FAILED=$((FAILED + 1))
  fi
}

skip_check() {
  local id="$1"
  local label="$2"
  local reason="$3"
  printf 'SKIP | %s | %s\n' "$label" "$reason" >> "$SUMMARY"
  printf '## – %s\n\nNão executado: %s\n\n' "$label" "$reason" >> "$REPORT"
  SKIPPED=$((SKIPPED + 1))
}

check_documentation() {
  local missing=0
  for file in README.md docs/ARCHITECTURE.md docs/CONTRIBUTING.md; do
    if [[ ! -s "$PROJECT_ROOT/$file" ]]; then
      printf 'Ausente ou vazio: %s\n' "$file"
      missing=1
    fi
  done
  [[ -d "$PROJECT_ROOT/docs/adr" ]] || { echo 'Diretório ausente: docs/adr'; missing=1; }
  return "$missing"
}

main() {
  cd "$PROJECT_ROOT" || exit 2
  prepare_output

  local maven='./mvnw'
  [[ -x "$maven" ]] || maven='mvn'

  run_check formatting 'Formatação' "$maven" -q spotless:check
  run_check conventions 'Convenções' "$maven" -q checkstyle:check
  run_check pmd 'Análise PMD' "$maven" -q pmd:check
  run_check spotbugs 'Possíveis bugs' "$maven" -q spotbugs:check
  run_check architecture 'Arquitetura' "$maven" -q -Dtest=ArchitectureTest test
  run_check tests 'Testes' "$maven" -q test
  run_check coverage 'Cobertura' "$maven" -q jacoco:report

  if command -v gitleaks >/dev/null 2>&1; then
    run_check security 'Secrets' gitleaks git --redact --no-banner
  else
    skip_check security 'Secrets' 'Gitleaks não está instalado.'
  fi

  run_check documentation 'Documentação essencial' check_documentation

  printf '\nAprovadas: %s | Falhas: %s | Ignoradas: %s\n' "$PASSED" "$FAILED" "$SKIPPED" | tee -a "$SUMMARY"
  printf '\nRelatório: %s\n' "$REPORT"
  (( FAILED == 0 ))
}

main "$@"
