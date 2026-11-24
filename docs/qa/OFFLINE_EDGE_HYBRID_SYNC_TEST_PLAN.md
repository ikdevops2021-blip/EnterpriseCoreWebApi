# QA Test Plan: Offline Edge Resilience & Hybrid Sync Engine

**Document Version:** 1.0.0  
**Feature:** Offline Edge Resilience & Hybrid Sync Engine (Script 41)  
**Target Coverage:** Unit Tests, Conflict Resolution Invariants, LAN SignalR Chime Tests, Multi-Teller Concurrency, and End-to-End Reconciliation.

---

## 1. Test Matrix Overview

| Test ID | Test Category | Target Component | Success Criteria |
|---|---|---|---|
| **TEST-EDGE-01** | Anti-Collision Keying | `ClientTokenGuid` / UUIDv7 Generator | 100,000 generated tokens exhibit 0 duplicate GUIDs and strictly monotonic timestamp ordering. |
| **TEST-EDGE-02** | Local SQLite Journaling | `EdgeSyncJournal` Engine | Offline token creation and state updates append sequentially with `IsSynced = 0`. |
| **TEST-EDGE-03** | State Machine Dominance | Conflict Resolution Resolver | Completed (18007) dominates over Canceled (18006); Active dominates over Queued. |
| **TEST-EDGE-04** | Cloud Ingestion Idempotency | `PR_IU_ProcessEdgeSyncBatch` | Re-submitting the same batch twice produces 0 duplicate records and returns status `AlreadyIngested`. |
| **TEST-EDGE-05** | Multi-Teller LAN Concurrency | Local SQLite Token Allocator | 10 simulated concurrent tellers calling tokens offline never receive the same token ID. |
| **TEST-EDGE-06** | WAN Failover & Recovery Detection | Network Health Watchdog | System switches from Cloud to Edge Autonomous within 3s of WAN loss; initiates sync within 2s of recovery. |
| **TEST-EDGE-07** | Clock Skew Robustness | Timestamp Reconciliation | Edge nodes with $\pm 15$ min time offset are correctly ordered by sequence number and monotonic UUIDv7. |
| **TEST-EDGE-08** | Edge Node Authentication | HMAC-SHA256 Token Validator | Rejects unauthorized edge sync requests with invalid secret key or expired timestamp (> 300s). |
| **TEST-EDGE-09** | Frontend Connectivity Banner | `EdgeResilienceBanner` Widget | Correctly transitions UI between Cloud (Green), Edge Offline (Amber), and Syncing (Blue). |
| **TEST-EDGE-10** | Admin Edge Console | `EdgeNodesView` Widget | Correctly lists registered edge nodes, last heartbeat, pending sync backlog, and trigger sync action. |

---

## 2. Detailed Test Cases & Execution Specifications

### TEST-EDGE-01: UUIDv7 Generation & Anti-Collision Verification
- **Objective:** Verify that `ClientTokenGuid` generated during offline Kiosk ticket creation is globally unique and timestamp-ordered.
- **Setup:** Generate 50,000 UUIDv7 values in parallel across 4 worker threads simulating 4 distributed edge branches.
- **Assertion:**
  - `Set.length == 50,000` (Zero collisions).
  - High 48 bits correspond to valid UTC Unix timestamp within 50ms of execution.
  - Sorting the list by string equals sorting by timestamp.

### TEST-EDGE-03: Conflict Resolution & State Dominance
- **Objective:** Verify that when cloud and edge states diverge during WAN disconnection, real-world physical teller service is never destroyed by remote client cancellation.
- **Scenario:**
  1. Token `OFF-A-010` is created at 10:00 AM on Edge Kiosk.
  2. At 10:15 AM, customer opens PWA and clicks "Cancel My Ticket" on Cloud SaaS (marked `Canceled`).
  3. At 10:16 AM, teller at physical counter calls `OFF-A-010` and serves patient, marking `Completed` on Edge Node.
  4. At 10:30 AM, WAN is restored and Edge Node syncs batch to Cloud.
- **Assertion:**
  - Cloud database record for `OFF-A-010` finishes in state `Completed` (`18007`).
  - An entry in `EdgeSyncAuditLog` records `ConflictType = 'CANCELED_VS_COMPLETED'`, `Resolution = 'TELLER_SERVICE_DOMINANT'`.

### TEST-EDGE-04: Batch Ingestion Idempotency
- **Objective:** Ensure network timeouts during sync response transmission do not cause duplicate token records upon client retry.
- **Scenario:**
  1. Edge Node sends Batch #101 containing 25 tokens.
  2. Cloud inserts tokens and generates database commit, but HTTP response drops due to flaky WAN.
  3. Edge Node retries Batch #101 with the exact same `BatchId` and `ClientTokenGuid` list.
- **Assertion:**
  - Cloud detects existing `ClientTokenGuid` records via `UX_TokenTransaction_ClientTokenGuid`.
  - Stored procedure executes `ON CONFLICT DO NOTHING / UPDATE`, returning `Status = 'IdempotentSuccess'`.
  - Zero duplicate rows created in `TokenTransaction`.

### TEST-EDGE-05: Multi-Teller LAN Concurrency (Local SQLite)
- **Objective:** Ensure multiple teller stations calling tokens offline on branch LAN never double-call.
- **Scenario:**
  - Simulate 5 concurrent HTTP POST requests to `http://localhost:5000/api/v1/dqms/staff/counter/call` simultaneously.
- **Assertion:**
  - Local SQLite uses `BEGIN IMMEDIATE` or row locks to guarantee atomic queue assignment.
  - Each of the 5 tellers receives a distinct token.
  - No database lock exception thrown to clients.

---

## 3. Automated Test Execution Commands

```powershell
# 1. Backend Unit & Integration Tests
dotnet test DNAQMSAPI\DNAQMSAPI.Tests --filter "Category=EdgeResilience"

# 2. Frontend Widget & Unit Tests
cd dqms_frontend
flutter test test/edge_resilience_test.dart

# 3. Full Solution & Frontend Regression Verification
cd ..
dotnet build DNAQMSAPI\DNAQMSAPI.sln
cd dqms_frontend
flutter test test/webhook_engine_test.dart test/tat_variance_heatmap_test.dart test/n_level_pipeline_workflows_test.dart
```
