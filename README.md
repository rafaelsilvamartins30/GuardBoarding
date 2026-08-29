# GuardBoarding

[Português (Brasil)](README.pt-BR.md)

GuardBoarding is an open and adaptable example that connects onboarding and
software quality. It combines free tools, documentation, and a local script to
turn standards chosen by a team into feedback that is easier to run and read.

This repository is the technical artifact of an undergraduate Software
Engineering thesis. The case study uses Java, Spring Boot, Maven, Git, and
Shell, but the principle can be applied to other architectures and languages
with equivalent tools.

## What this project does not decide

GuardBoarding does not define the correct architecture, create universal rules,
or replace code review, well-designed tests, and human guidance. Files in this
repository are examples. Keep only what represents actual project decisions.

## Repository contents

```text
.
├── config/
│   ├── checkstyle/checkstyle.xml
│   ├── pmd/ruleset.xml
│   └── spotbugs/exclude.xml
├── docs/
│   ├── ARCHITECTURE.md
│   ├── CONTRIBUTING.md
│   ├── adr/README.md
│   └── pt-BR/                 # equivalent Portuguese documentation
├── examples/
│   ├── ArchitectureTest.java
│   └── pom-plugins.xml
├── tests/test-quality-check.sh
├── README.pt-BR.md
├── lefthook.yml
└── quality-check.sh
```

## Gradual installation

### 1. Copy the script and documentation

```bash
cp quality-check.sh /path/to/project/
cp -R docs /path/to/project/
chmod +x /path/to/project/quality-check.sh
```

Review `docs/ARCHITECTURE.md` and `docs/CONTRIBUTING.md`. Document the real
project before automating its rules.

### 2. Choose one small check

Start with formatting, for example. Read `examples/pom-plugins.xml`, select a
current compatible plugin version in your `pom.xml`, and verify the command:

```bash
./mvnw spotless:check
```

Add conventions, static analysis, architecture, tests, coverage, and security
as needed. Adopting every check is not required.

### 3. Adapt the configurations

- `config/checkstyle/checkstyle.xml`: basic naming examples;
- `config/pmd/ruleset.xml`: illustrative design rules;
- `config/spotbugs/exclude.xml`: justified exception location;
- `examples/ArchitectureTest.java`: ArchUnit layer dependencies;
- `lefthook.yml`: optional pre-push execution.

Thresholds and names should represent conventions discussed by the team.

### 4. Run the checks

English output is the default:

```bash
./quality-check.sh
./quality-check.sh --lang en
```

Portuguese output is also available:

```bash
./quality-check.sh --lang pt
```

The script deletes only `.quality/last-run`, runs the configured tools, and
generates:

```text
.quality/last-run/
├── raw/          # complete output from every command
├── summary.txt   # short pass/fail view
└── report.md     # deterministic explanations
```

The summary, headings, and GuardBoarding explanations follow `--lang`. Output
produced by Maven and third-party plugins is preserved verbatim so diagnostic
details are never altered by translation. PMD and SpotBugs XML reports are also
copied into `raw/`, and their main findings are normalized in `report.md` with
file, line, rule, priority, and message whenever those fields are available.

Each tool remains available for individual execution.

## Warnings, failures, and false positives

A failed check means that a configured tool found a condition that deserves
attention; it does not prove that the code contains a defect. PMD and SpotBugs
use rules, static models, bytecode patterns, and heuristics that cannot know all
runtime and business context, so they can report false positives.

GuardBoarding therefore treats findings as review hypotheses. It identifies the
source tool, normalizes file, line, rule, priority, and message when available,
adds deterministic guidance for known rule families, and falls back to neutral
guidance for unknown rules. The original log and XML remain the source of truth.
Fix a finding only after confirming it. If it is a justified false positive,
suppress or exclude it at the smallest possible scope and record the rationale.

Spotless is different: a formatting failure normally means that the file does
not match the configured formatter, not that the code is defective. If the
result is undesirable, review the team's formatting configuration before
changing code merely to satisfy it.

## Script customization

Edit the `run_check` calls near the end of `quality-check.sh`. Remove plugins
the project does not use, replace commands, and adapt explanations to actual
rules. When an explanation is not mapped, keep and inspect the original output.

Run the parser and guidance regression tests with:

```bash
./tests/test-quality-check.sh
```

## Documentation

English is the canonical documentation language in the root files. Equivalent
Portuguese files live under `docs/pt-BR/` and in `README.pt-BR.md`. When changing
documentation, update both versions in the same contribution.

Markdown keeps knowledge close to code, is clear in diffs, and can provide
structured context to LLM-assisted tools. Responsibility remains with the team:
AI-generated or AI-edited text must be reviewed, and important decisions need
human authorship and rationale.

Recommended documentation includes:

- a README with setup and daily commands;
- a contribution guide and Git flow conventions;
- a current architecture overview;
- ADRs for significant decisions;
- OpenAPI/Swagger for public API contracts;
- comments only when they explain context that code cannot communicate.

## Contributing

Read `docs/CONTRIBUTING.md`. Suggestions should explain the problem, context,
and why a change supports people or preserves a project decision.

## License

Distributed under the MIT License. See `LICENSE`.
