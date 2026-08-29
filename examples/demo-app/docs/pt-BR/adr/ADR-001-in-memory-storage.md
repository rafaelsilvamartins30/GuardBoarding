# ADR-001 — Armazenamento em Memória para a Aplicação Demo

## Status
Aceito

## Contexto
A aplicação de demonstração serve como referência educacional de ferramentas de qualidade sem exigir dependências externas como PostgreSQL ou Docker.

## Decisão
Utilizar coleções thread-safe em memória (`ConcurrentHashMap`) encapsuladas pela interface `MemberRepository`.

## Consequências
- Inicialização ultrarrápida e zero necessidade de infraestrutura externa.
- O estado reinicia entre execuções (perfeitamente aceitável para demonstração e testes automatizados).
