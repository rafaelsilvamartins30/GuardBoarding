# GuardBoarding

[English](README.md)

GuardBoarding é um exemplo aberto e adaptável para aproximar onboarding e
qualidade de software. O projeto reúne ferramentas gratuitas, documentação e um
script local para transformar padrões escolhidos por uma equipe em feedback
mais fácil de executar e compreender.

Este repositório é o artefato técnico de um Trabalho de Conclusão de Curso em
Engenharia de Software. O estudo de caso usa Java, Spring Boot, Maven, Git e
Shell, mas o princípio pode ser aplicado a outras arquiteturas e linguagens com
ferramentas equivalentes.

## O que este projeto não decide

GuardBoarding não define uma arquitetura correta, não cria regras universais e
não substitui code review, testes bem projetados ou orientação humana. Os
arquivos deste repositório são exemplos. A equipe deve manter apenas aquilo que
representa decisões reais do seu contexto.

## Conteúdo

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
│   └── pt-BR/                 # documentação equivalente em português
├── examples/
│   ├── ArchitectureTest.java
│   └── pom-plugins.xml
├── lefthook.yml
├── README.pt-BR.md
└── quality-check.sh
```

## Instalação gradual

### 1. Copie o script e a documentação

```bash
cp quality-check.sh /caminho/do/projeto/
cp -R docs /caminho/do/projeto/
chmod +x /caminho/do/projeto/quality-check.sh
```

Revise `docs/ARCHITECTURE.md` e `docs/CONTRIBUTING.md`. Documente o projeto real
antes de automatizar regras.

### 2. Escolha uma verificação pequena

Comece, por exemplo, com formatação. Consulte `examples/pom-plugins.xml`, fixe
uma versão atual e compatível do plugin no seu `pom.xml` e confirme o comando:

```bash
./mvnw spotless:check
```

Depois adicione convenções, análise estática, arquitetura, testes, cobertura e
segurança conforme a necessidade. Não é obrigatório adotar tudo.

### 3. Adapte as configurações

- `config/checkstyle/checkstyle.xml`: exemplos básicos de nomenclatura;
- `config/pmd/ruleset.xml`: regras ilustrativas de design;
- `config/spotbugs/exclude.xml`: local para exceções justificadas;
- `examples/ArchitectureTest.java`: dependências em camadas com ArchUnit;
- `lefthook.yml`: execução opcional antes de enviar commits.

Os limites e nomes devem representar convenções discutidas pela equipe.

### 4. Execute o conjunto

```bash
./quality-check.sh
./quality-check.sh --lang pt
```

O script remove somente `.quality/last-run`, executa as ferramentas configuradas
e gera:

```text
.quality/last-run/
├── raw/          # saída completa de cada comando
├── summary.txt   # visão curta de aprovação e falha
└── report.md     # explicações determinísticas
```

O resumo, os títulos e as explicações do GuardBoarding seguem a opção `--lang`.
A saída produzida pelo Maven e por plugins externos é preservada sem tradução
para não alterar detalhes de diagnóstico. Os XMLs de PMD e SpotBugs também são
copiados para `raw/`, e seus principais achados aparecem normalizados em
`report.md` com arquivo, linha, regra, prioridade e mensagem quando esses campos
estão disponíveis.

Cada ferramenta também pode continuar sendo executada individualmente.

## Personalização do script

Edite as chamadas `run_check` no final de `quality-check.sh`. Remova plugins que
o projeto não usa, troque comandos e adapte `explanation_for` às regras reais.
Quando uma explicação não estiver mapeada, preserve e consulte a saída original.

## Documentação

O inglês é o idioma canônico dos arquivos na raiz. As versões equivalentes em
português ficam em `README.pt-BR.md` e `docs/pt-BR/`. Uma mudança documental
deve atualizar os dois idiomas na mesma contribuição.

Markdown mantém conhecimento próximo do código, aparece claramente em diffs e
pode fornecer contexto estruturado para ferramentas assistidas por LLMs. Isso
não transfere a responsabilidade da equipe: texto gerado ou alterado com IA deve
ser revisado, e decisões importantes precisam de autoria e justificativa humana.

Recomenda-se manter:

- README com instalação e comandos cotidianos;
- guia de contribuição;
- visão atual da arquitetura;
- ADRs para decisões determinantes;
- OpenAPI/Swagger para contratos públicos da API;
- comentários apenas quando explicam contexto que o código não comunica.

## Docker é opcional

Um container pode padronizar Java, Maven e ferramentas auxiliares. Use-o quando
a reprodutibilidade compensar a camada operacional adicional. GuardBoarding não
depende de Docker e deve continuar simples de executar localmente.

## Contribuição

Leia `docs/CONTRIBUTING.md`. Sugestões devem explicar o problema, o contexto e
por que a mudança ajuda pessoas ou preserva uma decisão de projeto.

## Licença

Distribuído sob a licença MIT. Consulte `LICENSE`.
