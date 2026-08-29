# GuardBoarding Demo App (Team Onboarding API)

[Português (Brasil)](README.pt-BR.md)

A complete, fully working reference implementation of a Spring Boot 3 REST API configured with the GuardBoarding quality guardrails.

---

## 📋 Tested & Homologated Version Matrix

This matrix provides a proven, conflict-free combination of Java, Spring Boot, and quality plugins for build reproducibility:

| Component | Tested Version | Scope | Rationale / Purpose |
| :--- | :--- | :--- | :--- |
| **Java SDK** | `17 LTS` / `21 LTS` | Runtime | Modern LTS runtime standards. |
| **Spring Boot** | `3.3.3` | Framework | Jakarta EE baseline and modern Web API. |
| **Spotless Maven Plugin** | `2.43.0` | Build plugin | Google Java Format (`1.22.0`) formatting. |
| **Maven Checkstyle Plugin** | `3.4.0` (Checkstyle `10.17.0`) | Build plugin | Lexical and naming convention enforcement. |
| **Maven PMD Plugin** | `3.24.0` (PMD `7.4.0`) | Build plugin | Cognitive complexity & GodClass detection. |
| **SpotBugs Maven Plugin** | `4.8.6.2` | Build plugin | Bytecode static analysis for potential bugs. |
| **ArchUnit JUnit 5** | `1.3.0` | Test dependency | Architectural layer boundaries verification. |
| **JaCoCo Plugin** | `0.8.12` | Build plugin | Deterministic code coverage reporting. |
| **Gitleaks** | `8.x+` | CLI Tool | Pre-push secret leakage prevention. |

---

## 🚀 Quick Start

Run the quality check directly inside this directory:

```bash
cd examples/demo-app
./quality-check.sh
```

To run with Portuguese reports:
```bash
./quality-check.sh --lang pt
```

To automatically format files:
```bash
./quality-check.sh --fix
```

---

## 🧪 Hands-on Quality Lab (Learning Experiments)

Try these short 1-minute experiments to see how GuardBoarding catches violations and guides remediation:

### Experiment 1: Architectural Boundary Violation (ArchUnit)
1. Open `src/main/java/com/guardboarding/demo/controller/MemberController.java`.
2. Inject `MemberRepository` directly into `MemberController` instead of `MemberService`.
3. Run `./quality-check.sh --only architecture`.
4. **Expected Result:** ArchUnit fails, preventing Controller-to-Repository coupling.

### Experiment 2: Formatting Auto-Remediation (Spotless)
1. Introduce messy indentation or extra blank lines in any Java class.
2. Run `./quality-check.sh --only formatting`. Spotless will fail.
3. Run `./quality-check.sh --fix`. Spotless automatically fixes the formatting according to Google Java Style.

### Experiment 3: Cognitive Complexity (PMD)
1. Add a method with 10 deeply nested `if/else` loops in `MemberService.java`.
2. Run `./quality-check.sh --only pmd`.
3. **Expected Result:** PMD flags `CognitiveComplexity` and points to the exact line in `report.md`.

### Experiment 4: Sensitive Files Detection
1. Create a dummy `.env` file in the project.
2. Stage it with `git add .env`.
3. Run `./quality-check.sh --only sensitive_files`.
4. **Expected Result:** The check immediately flags the tracked `.env` file before pushing.
