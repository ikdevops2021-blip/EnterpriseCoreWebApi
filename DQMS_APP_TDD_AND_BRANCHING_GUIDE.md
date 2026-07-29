# 🧪 Enterprise TDD Development Strategy & Git Branching Pipeline for `DQMS_APP`

This document defines the **Test-Driven Development (TDD)** methodology, **Git Branching Strategy**, and **Automated CI/CD Build Pipelines** for the `DQMS_APP` repository.

---

## 📌 1. Git Branching Strategy & Environments

`DQMS_APP` operates on a 3-tier branch model corresponding to distinct deployment environments:

```
[Feature Branch]  ──(PR)──>  [develop]  ──(PR/Merge)──>  [qa]  ──(PR/Release)──>  [main / production]
  (Local Dev)             (Development)              (Staging / QA)               (Production)
```

| Branch Name | Deployment Environment | Access / Role | Auto CI/CD Trigger |
| :--- | :--- | :--- | :--- |
| `develop` | **Development** | Active feature integration, daily developer testing | Build + Unit Tests + Dev Deployment |
| `qa` | **QA / Staging** | Quality Assurance, automated E2E integration tests | Build + Integration Tests + QA Deployment |
| `main` / `production` | **Production** | Live production releases | Full Release Build + Prod Deployment |
| `feature/*` | **Local Sandbox** | Individual feature or user story work | PR Validation Build + Unit Tests |

---

## 🔁 2. Test-Driven Development (TDD) Workflow

All backend Web API endpoints, domain logic, and frontend components in `DQMS_APP` must follow strict **Red-Green-Refactor TDD rules**:

```
 ┌─────────────────────────────────────────────────────────┐
 │ 1. RED Phase: Write a failing Unit/Integration Test     │
 └────────────────────────────┬────────────────────────────┘
                              │
                              ▼
 ┌─────────────────────────────────────────────────────────┐
 │ 2. GREEN Phase: Write minimal code to make test PASS   │
 └────────────────────────────┬────────────────────────────┘
                              │
                              ▼
 ┌─────────────────────────────────────────────────────────┐
 │ 3. REFACTOR Phase: Clean up architecture & optimize     │
 └─────────────────────────────────────────────────────────┘
```

### TDD Rules for Developers & AI:
1. **Never write implementation code without a failing test first**: Create unit test classes in test projects (`DNAQMSAPI.UnitTests` / `DNAQMSAPI.IntegrationTests`).
2. **Mock External Dependencies**: Use `Moq` or `NSubstitute` to mock `IDapperDBFactory`, HTTP clients, and external gateways during unit testing.
3. **Integration Test Suite**: Use WebApplicationFactory and test databases (or SQLite in-memory / containerized DBs) to test full HTTP request-response cycles.
4. **Code Coverage Target**: Maintain **minimum 85% code coverage** on domain services and application handlers before merging to `develop`.

---

## ⚙️ 3. GitHub Actions CI/CD Build Pipelines

Create `.github/workflows` in `DQMS_APP` to automate testing and build validation across all branches:

### Pipeline 1: Pull Request & Feature Validation (`pr-validation.yml`)
Triggers on any PR to `develop` or `qa`:
- Restores dependencies and builds solution.
- Runs all Unit & Integration tests (`dotnet test`).
- Fails PR merge if any test fails or coverage drops below threshold.

### Pipeline 2: Develop Deployment Pipeline (`develop-ci.yml`)
Triggers on commit to `develop`:
- Runs test suites.
- Packages Web API Docker container (`docker build`).
- Deploys automatically to the **Development Environment**.

### Pipeline 3: QA & Staging Release (`qa-ci.yml`)
Triggers on commit or PR merge to `qa`:
- Executes full integration and database migration tests (`SeederApp`).
- Runs HTTP API verification scripts (`run-qa-tests-http.ps1`).
- Deploys container to **QA / Staging Environment**.

### Pipeline 4: Production Release Pipeline (`prod-release.yml`)
Triggers on release tag or merge to `main`:
- Build production release bundle.
- Deploys to **Production Environment** with zero-downtime rolling update.

---

## 📝 Initial Setup Checklist for `DQMS_APP`

When setting up the `DQMS_APP` project workspace:

1. [ ] Initialize local repository linked to `https://github.com/ikdevops2021-blip/DQMS_APP.git`.
2. [ ] Create primary branches: `develop`, `qa`, and `main`.
3. [ ] Add `DNAQMSAPI.UnitTests` and `DNAQMSAPI.IntegrationTests` projects to the solution.
4. [ ] Configure GitHub Actions workflows under `.github/workflows/`.
5. [ ] Enforce branch protection rules on `develop`, `qa`, and `main` requiring PR approvals and green CI test builds.
