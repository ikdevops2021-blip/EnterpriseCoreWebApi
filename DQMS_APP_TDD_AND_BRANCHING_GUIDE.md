# 🧪 Enterprise TDD Development Strategy & Git Branching Pipeline for `DQMS_APP`

This document defines the **Test-Driven Development (TDD)** methodology, **Git Branching Strategy**, **Hotfix Workflow**, **Feature Flags**, and **Automated CI/CD Build Pipelines** for the `DQMS_APP` repository.

---

## 📌 1. Git Branching Model & Environment Pipeline

`DQMS_APP` operates on a 3-tier branch model with short-lived feature and hotfix branches:

```
[feature/*]  ──(PR)──>  [develop]  ──(PR/Merge)──>  [qa]  ──(PR/Release)──>  [main / production]
  (Local Dev)             (Development)              (Staging / QA)               (Production)
                                                                                       │
                                                                               (Critical Bug!)
                                                                                       │
                                                                                       ▼
                                                                               [hotfix/vX.X.X]
```

| Branch Pattern | Target Environment | Purpose & Trigger Rules | Auto CI/CD Action |
| :--- | :--- | :--- | :--- |
| `feature/*` | **Local Sandbox** | Individual feature or task branch (lives < 48 hours). | PR Validation + Unit Tests |
| `develop` | **Development** | Active integration branch for developer testing. | Build + Unit Tests + Dev Deploy |
| `qa` | **QA / Staging** | Staging environment for QA testing & verification. | Migration Tests + Integration Tests + QA Deploy |
| `main` | **Production** | Live production release branch (controlled by release tags). | Full Release Build + Zero-Downtime Deploy |
| `hotfix/*` | **Hotfix Patch** | Urgent production bug fixes branched directly from `main` or release tag. | Immediate Prod CI/CD + Backport |

---

## 🚨 2. Production Hotfix Management Workflow

When a critical bug occurs in Production, follow this strict 5-step hotfix protocol:

```
1. Create Branch  ──►  2. TDD Regression Test  ──►  3. Fix & Pass  ──►  4. Release Prod  ──►  5. Backport
 hotfix/v1.0.1           Write failing test           Verify GREEN         Tag v1.0.1           Merge to develop
```

### Hotfix Execution Steps:
1. **Branch Creation**:
   ```bash
   git checkout -b hotfix/v1.0.1 v1.0.0
   ```
2. **Mandatory TDD Regression Test**: Write a unit/integration test reproducing the production crash before writing fix code.
3. **Fix Implementation**: Apply minimal code fix until test turns **GREEN**.
4. **Production Deployment**: Tag and push to trigger immediate production release pipeline:
   ```bash
   git tag -a v1.0.1 -m "Hotfix v1.0.1 for Production"
   git push origin v1.0.1
   ```
5. **Dual Backport**: Merge the hotfix back into `develop` and sync core improvements back to `upstream` (`EnterpriseCoreWebApi`):
   ```bash
   git checkout develop
   git merge hotfix/v1.0.1 -m "Backport hotfix v1.0.1 into develop"
   git push origin develop
   git push upstream develop
   ```

---

## 🚩 3. Feature Flags (Decoupling Deployment from Release)

To prevent unfinished features from breaking production when merging code into `develop` or `main`, `DQMS_APP` uses **.NET Feature Management** (`Microsoft.FeatureManagement`).

### Implementation Blueprint:
1. **Controller / Endpoint Guarding**:
   ```csharp
   [FeatureGate("EnableNewTaxEngine")]
   [HttpPost("api/v1/tax/calculate")]
   public async Task<IActionResult> CalculateTax([FromBody] TaxRequestDto request)
   {
       // Feature logic
   }
   ```
2. **Dynamic Configuration (`appsettings.json`)**:
   ```json
   "FeatureManagement": {
     "EnableNewTaxEngine": false,
     "EnableStripeUPIPayment": true
   }
   ```

---

## 🧪 4. Test-Driven Development (TDD) Strategy

All backend endpoints, domain logic, and frontend components in `DQMS_APP` follow strict **Red-Green-Refactor TDD rules**:

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
 └────────────────────────────┬────────────────────────────┘
```

### Testing Layers & Tools:

#### A. Domain Unit Tests (60% of Tests)
- **Scope**: Core domain entities, value objects, and pure business calculations.
- **Rule**: Zero external dependencies, no database connections, no HTTP mocks. Runs in milliseconds.

#### B. Integration Testing with `Testcontainers` (30% of Tests)
Instead of fragile repository mocking, integration tests use **`Testcontainers.MySql`** or **`Testcontainers.MsSql`** to execute tests against a real containerized database instance:
```csharp
public class IntegrationTestBase : IAsyncLifetime
{
    private readonly MySqlContainer _dbContainer = new MySqlBuilder()
        .WithDatabase("test_db")
        .Build();

    public async Task InitializeAsync()
    {
        await _dbContainer.StartAsync();
        // Run SeederApp migration scripts against _dbContainer.GetConnectionString()
    }
}
```

#### C. Automated Architecture Tests (`NetArchTest`) (10% of Tests)
Enforce Clean Architecture boundaries automatically in CI/CD so developers cannot accidentally violate layer dependencies:
```csharp
[Fact]
public void DomainLayer_ShouldNotDependOn_Infrastructure()
{
    var result = Types.InAssembly(typeof(User).Assembly)
        .ShouldNot()
        .HaveDependencyOn("DNAQMSAPI.Infrastructure")
        .GetResult();

    Assert.True(result.IsSuccessful);
}
```

---

## ⚙️ 5. GitHub Actions CI/CD Build Pipelines

Create `.github/workflows` in `DQMS_APP` to automate testing and build validation across all branches:

### Pipeline 1: Pull Request & Feature Validation (`pr-validation.yml`)
Triggers on any PR to `develop` or `qa`:
- Restores dependencies and builds solution.
- Runs all Unit, Integration (`Testcontainers`), and Architecture (`NetArchTest`) tests.
- Fails PR merge if any test fails or coverage drops below 85%.

### Pipeline 2: Develop Deployment Pipeline (`develop-ci.yml`)
Triggers on commit to `develop`:
- Runs full test suite.
- Builds Web API Docker container (`docker build`).
- Deploys automatically to the **Development Environment**.

### Pipeline 3: QA & Staging Release (`qa-ci.yml`)
Triggers on commit or PR merge to `qa`:
- Executes DB migration scripts (`SeederApp`).
- Runs HTTP API verification scripts (`run-qa-tests-http.ps1`).
- Deploys container to **QA / Staging Environment**.

### Pipeline 4: Production Release Pipeline (`prod-release.yml`)
Triggers on release tag (`v*.*.*`) or merge to `main`:
- Builds production release bundle.
- Deploys to **Production Environment** with zero-downtime rolling update.

---

## 📝 Initial Setup Checklist for `DQMS_APP`

When setting up the `DQMS_APP` project workspace:

1. [ ] Initialize local repository linked to `https://github.com/ikdevops2021-blip/DQMS_APP.git`.
2. [ ] Create primary branches: `develop`, `qa`, and `main`.
3. [ ] Add `DNAQMSAPI.UnitTests`, `DNAQMSAPI.IntegrationTests`, and `DNAQMSAPI.ArchitectureTests` projects.
4. [ ] Configure GitHub Actions workflows under `.github/workflows/`.
5. [ ] Enforce branch protection rules requiring PR approvals and green CI test builds.
