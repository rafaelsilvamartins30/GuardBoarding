# Como contribuir

## Preparação

1. Leia `README.md` e `docs/ARCHITECTURE.md`.
2. Instale as versões de Java e Maven definidas pelo projeto.
3. Execute os testes antes de alterar o código.

## Durante a mudança

- siga as convenções versionadas no repositório;
- escreva testes para o comportamento alterado;
- atualize contratos e documentação afetados;
- crie ou atualize um ADR quando a decisão for arquitetural.

## Antes de compartilhar

```bash
./quality-check.sh
```

Leia primeiro `.quality/last-run/report.md`. Use os arquivos em `raw/` para o
diagnóstico completo.

Uma contribuição pode propor a revisão de uma regra. Explique contexto e
trade-offs em vez de apenas desabilitar a verificação.
