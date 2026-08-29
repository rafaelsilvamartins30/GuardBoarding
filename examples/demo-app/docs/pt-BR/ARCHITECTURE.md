# Arquitetura do Demo App

[English](../ARCHITECTURE.md)

Esta aplicação é a implementação de referência da **Team Onboarding API** gerenciada com os padrões do GuardBoarding.

## Contexto

O sistema gerencia membros de equipe e o status de onboarding por meio de uma API REST leve.

## Arquitetura em Camadas

```text
Controller → Service → Repository
```

- **Controller (`com.guardboarding.demo.controller`)**: Expõe endpoints REST, valida payloads com Jakarta Validation e retorna DTOs.
- **Service (`com.guardboarding.demo.service`)**: Implementa regras de negócio, garante unicidade de e-mail e coordena mudanças de estado.
- **Repository (`com.guardboarding.demo.repository`)**: Gerencia armazenamento de membros (repositório em memória concorrente).
- **Model / DTO (`com.guardboarding.demo.model`, `com.guardboarding.demo.dto`)**: Modelos de domínio puros e objetos de transferência desacoplados.

## Regras Automatizadas

As dependências são estritamente verificadas pelo **ArchUnit** em `ArchitectureTest.java`:
1. Controllers não podem acessar Repositories diretamente.
2. Services orquestram a lógica de negócio.
