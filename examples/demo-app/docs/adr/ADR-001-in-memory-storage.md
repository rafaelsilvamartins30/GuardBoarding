# ADR-001 — In-Memory Storage for Demo Application

## Status
Accepted

## Context
The demo application serves as an educational reference for quality tools without requiring external database dependencies like PostgreSQL or Docker.

## Decision
Use thread-safe in-memory collections (`ConcurrentHashMap`) behind a `MemberRepository` interface.

## Consequences
- Fast startup and zero external infrastructure requirements.
- State resets between application restarts (acceptable for demonstration and automated testing).
