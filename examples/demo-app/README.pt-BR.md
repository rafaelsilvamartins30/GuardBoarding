# GuardBoarding Demo App (Team Onboarding API)

[English](README.md)

Uma implementação de referência completa, funcional e homologada de uma API REST Spring Boot 3 configurada com todos os guardrails de qualidade do GuardBoarding.

---

## 📋 Matriz Oficial de Versões Homologadas

Esta matriz apresenta uma combinação testada e livre de conflitos entre Java, Spring Boot e plugins de qualidade para garantir reproducibilidade:

| Componente | Versão Testada | Escopo | Justificativa / Papel |
| :--- | :--- | :--- | :--- |
| **Java SDK** | `17 LTS` / `21 LTS` | Runtime | Padrão LTS moderno da indústria. |
| **Spring Boot** | `3.3.3` | Framework | Padrão Jakarta EE e APIs REST modernas. |
| **Spotless Maven Plugin** | `2.43.0` | Plugin Maven | Formatação com Google Java Format (`1.22.0`). |
| **Maven Checkstyle Plugin** | `3.4.0` (Checkstyle `10.17.0`) | Plugin Maven | Validação de convenções de nomenclatura. |
| **Maven PMD Plugin** | `3.24.0` (PMD `7.4.0`) | Plugin Maven | Detecção de complexidade cognitiva e GodClass. |
| **SpotBugs Maven Plugin** | `4.8.6.2` | Plugin Maven | Análise estática de bytecode para possíveis bugs. |
| **ArchUnit JUnit 5** | `1.3.0` | Dependência Test | Verificação de fronteiras arquiteturais em camadas. |
| **JaCoCo Plugin** | `0.8.12` | Plugin Maven | Relatório determinístico de cobertura de código. |
| **Gitleaks** | `8.x+` | Ferramenta CLI | Prevenção contra vazamento de segredos no Git. |

---

## 🚀 Início Rápido

Execute a verificação de qualidade diretamente dentro desta pasta:

```bash
cd examples/demo-app
./quality-check.sh
```

Para executar com relatório em português:
```bash
./quality-check.sh --lang pt
```

Para aplicar formatação automática:
```bash
./quality-check.sh --fix
```

---

## 🧪 Laboratório Prático de Qualidade (Experimentos Educativos)

Experimente estas simulações rápidas de 1 minuto para ver o GuardBoarding em ação:

### Experimento 1: Quebra de Fronteira Arquitetural (ArchUnit)
1. Abra `src/main/java/com/guardboarding/demo/controller/MemberController.java`.
2. Injete `MemberRepository` diretamente no `MemberController` em vez do `MemberService`.
3. Execute `./quality-check.sh --only architecture`.
4. **Resultado Esperado:** O ArchUnit falha, impedindo o acoplamento direto entre Controller e Repository.

### Experimento 2: Auto-Correção de Formatação (Spotless)
1. Desalinhe a indentação ou adicione quebras de linha irregulares em qualquer classe Java.
2. Execute `./quality-check.sh --only formatting`. O Spotless acusará a falha.
3. Execute `./quality-check.sh --fix`. O Spotless formata os arquivos automaticamente no padrão Google Java Style.

### Experimento 3: Complexidade Cognitiva (PMD)
1. Crie um método com múltiplos `if/else` profundamente aninhados em `MemberService.java`.
2. Execute `./quality-check.sh --only pmd`.
3. **Resultado Esperado:** O PMD sinaliza `CognitiveComplexity` indicando a linha exata no `report.md`.

### Experimento 4: Detecção de Arquivos Sensíveis
1. Crie um arquivo fictício `.env` na pasta.
2. Adicione ao índice do Git com `git add .env`.
3. Execute `./quality-check.sh --only sensitive_files`.
4. **Resultado Esperado:** A verificação bloqueia imediatamente o arquivo rastreado antes do push.
