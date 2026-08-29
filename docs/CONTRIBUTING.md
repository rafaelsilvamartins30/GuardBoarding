# Contributing

[Português (Brasil)](pt-BR/CONTRIBUTING.md)

## Preparation

1. Read `README.md` and `docs/ARCHITECTURE.md`.
2. Install the Java and Maven versions defined by the project.
3. Run tests before changing code.

## Git conventions

The project should document its chosen Git flow. A simple example is:

1. create `feature/short-description` from the integration branch;
2. keep commits focused and descriptive;
3. open a pull request to `develop`;
4. require review and automated checks;
5. merge `develop` into protected `main` only for publication or release.

Adapt branch names and flow to the team. Protect shared branches to prevent
direct pushes and require the checks that the project considers mandatory.

## During a change

- follow conventions versioned in the repository;
- write tests for changed behavior;
- update affected contracts and documentation;
- create or update an ADR for architectural decisions.

## Before sharing

```bash
./quality-check.sh
```

Read `.quality/last-run/report.md` first. Use files in `raw/` for complete
diagnostics.

A contribution may propose revising a rule. Explain context and trade-offs
instead of only disabling the check.
