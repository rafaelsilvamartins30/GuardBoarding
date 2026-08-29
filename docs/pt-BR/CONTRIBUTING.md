# Como contribuir

[English](../CONTRIBUTING.md)

## Preparação

1. Leia `README.md` e `docs/ARCHITECTURE.md`.
2. Instale as versões de Java e Maven definidas pelo projeto.
3. Execute os testes antes de alterar o código.

## Convenções de Git

O projeto deve documentar o fluxo Git escolhido. Um exemplo simples é:

1. criar `feature/descricao-curta` a partir da branch de integração;
2. manter commits focados e descritivos;
3. abrir um pull request para `develop`;
4. exigir revisão e verificações automatizadas;
5. integrar `develop` à `main` protegida somente para publicação ou release.

Adapte nomes e fluxo à equipe. Proteja branches compartilhadas para impedir
push direto e exigir as verificações consideradas obrigatórias.

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
