# Demo App Architecture

[Português (Brasil)](pt-BR/ARCHITECTURE.md)

This application is a reference implementation of the **Team Onboarding API** managed with GuardBoarding quality guardrails.

## Context

The system manages team members and their onboarding status through a lightweight REST API.

## Layered Architecture

```text
Controller → Service → Repository
```

- **Controller (`com.guardboarding.demo.controller`)**: Exposes REST endpoints, validates request payloads with Jakarta Validation, and returns DTOs.
- **Service (`com.guardboarding.demo.service`)**: Implements business rules, ensures email uniqueness, and coordinates state changes.
- **Repository (`com.guardboarding.demo.repository`)**: Manages member storage (in-memory concurrent store).
- **Model / DTO (`com.guardboarding.demo.model`, `com.guardboarding.demo.dto`)**: Pure domain models and decoupled transfer objects.

## Enforced Rules

Dependencies are strictly verified by **ArchUnit** in `ArchitectureTest.java`:
1. Controllers must not access Repositories directly.
2. Services orchestrate business logic.
