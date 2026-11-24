# Technical Architecture & Engineering Plan: Offline Edge Resilience & Hybrid Sync Engine

**Document Version:** 1.0.0  
**Target System:** DQMS Enterprise (.NET 8 Core Web API + Flutter Multiplatform Frontend + Dual DB MSSQL/MySQL + Local Edge Daemon)  
**Feature Scope:** Zero-Downtime Local Branch Queue Continuity, Local SQLite Edge Journal, ClientTokenGuid UUIDv7 Anti-Collision, LAN SignalR Chime Hub, and Automated Cloud Reconciliation Protocol.

---

## 1. Executive Summary & Problem Space

### 1.1 The Operational Disaster of WAN Outages
In hospitals, airports, municipal centers, and banking branches, physical crowds of hundreds of customers are gathered in waiting lobbies. If the wide-area network (WAN) or cloud internet connection drops:
1. **The Walkout & Riot Risk:** Entrance kiosks stop dispensing tickets; teller workstations freeze and cannot call waiting customers; TV display screens blank out or display loading spinners. Physical chaos ensues within minutes.
2. **The "Pure Client-Side" Fallacy:** Running isolated offline storage (e.g. browser `IndexedDB` or device `sqflite`) directly on each tablet/PC fails catastrophically because multiple tellers in the same lobby cannot see each other's tokens without a shared local network broker. Teller 1 and Teller 2 call the exact same token simultaneously.
3. **The Synchronization Collision Trap:** When the internet returns, bulk inserting offline tokens with simple auto-increment IDs into a multi-tenant Cloud database causes catastrophic primary key collisions, duplicate ticket numbers, and mangled audit sequences.

### 1.2 The Core Mandate
This engineering specification designs a rock-solid, enterprise-grade **Offline Edge Resilience & Hybrid Sync Engine** satisfying the **Zero-Disruption Invariant**:
> **When internet to the cloud is completely severed, the physical branch continues operating 100% autonomously: Kiosks print tickets, Tellers call next, TV displays chime and flash numbers, and when WAN connectivity is restored, all offline transactions reconcile into the Cloud SaaS with zero data loss, zero duplicate keys, and automated conflict resolution.**

---

## 2. System Architecture & Topology

```
+---------------------------------------------------------------------------------------------------------+
|                                        BRANCH LOCAL AREA NETWORK (LAN)                                  |
|                                                                                                         |
|   +---------------------+       +----------------------+       +------------------------------------+   |
|   |   Entrance Kiosk    |       |   Staff Counter(s)   |       |      Waiting Room TV Screen        |   |
|   |  (Flutter Desktop)  |       |  (Flutter Windows)   |       |       (Android / Chrome 4K)        |   |
|   +----------+----------+       +-----------+----------+       +-----------------+------------------+   |
|              |                              |                                    |                      |
|              +------------------------------+------------------------------------+                      |
|                                             | Local HTTP / WebSocket (SignalR)                          |
|                                             v                                                           |
|                       +---------------------------------------------+                                   |
|                       |    DQMS LOCAL BRANCH EDGE DAEMON (NODE)     |                                   |
|                       |   (Lightweight .NET 8 / Kestrel / LAN)      |                                   |
|                       |                                             |                                   |
|                       |  * Local SQLite DB (dqms_edge.db)           |                                   |
|                       |  * Local SignalR Hub (LAN Chimes & Calling) |                                   |
|                       |  * Append-Only Outbound Sync Journal        |                                   |
|                       |  * Cloud WAN Health Watchdog (3s ping)      |                                   |
|                       +---------------------+-----------------------+                                   |
+---------------------------------------------|-----------------------------------------------------------+
                                              |
                             WAN INTERNET (Cloud Connectivity)
                      [ONLINE: Transparent Proxy | OFFLINE: Local Journaling]
                                              |
                                              v
+---------------------------------------------------------------------------------------------------------+
|                                          CLOUD SAAS PLATFORM                                            |
|                                                                                                         |
|   +-------------------------------------------------------------------------------------------------+   |
|   |                        DNAQMSAPI (.NET 8 Core Web API + Clean Architecture)                     |   |
|   |                                                                                                 |   |
|   |   * EdgeSyncController: POST /api/v1/dqms/edge/sync (Idempotent Delta Batch Ingestion)          |   |
|   |   * Stored Procedure: PR_IU_ProcessEdgeSyncBatch (MSSQL & MySQL Script 41)                      |   |
|   |   * Conflict Resolution: UUIDv7 Invariant Matcher + State Dominance Engine                      |   |
|   +-------------------------------------------------+-----------------------------------------------+   |
|                                                     |                                                   |
|                                                     v                                                   |
|                              +---------------------------------------------+                            |
|                              |      CENTRAL DATABASE (MSSQL / MySQL 8.0)   |                            |
|                              |                                             |                            |
|                              |  * TokenTransaction (ClientTokenGuid UX)    |                            |
|                              |  * EdgeNodeRegistration                     |                            |
|                              |  * EdgeSyncAuditLog                         |                            |
|                              +---------------------------------------------+                            |
+---------------------------------------------------------------------------------------------------------+
```

---

## 3. Operational State Machine: 3 Operating Modes

### 3.1 Mode 1: Online Mode (Transparent Cloud Proxy + Warm Mirror)
- The Edge Gateway runs on the branch LAN (e.g. `http://192.168.1.50:5000`).
- Local devices (Kiosk, Counter, TV) send API requests to the Edge Gateway.
- Edge Gateway proxies requests directly to Cloud SaaS.
- **Warm Mirroring:** Successful configuration queries (Categories, Parameters, Process Steps, Staff, Counters) are asynchronously cached into local SQLite (`dqms_edge.db`). If WAN drops in the next second, local configuration is 100% populated.

### 3.2 Mode 2: Edge Autonomous Mode (WAN Severed / Offline)
- The Edge Gateway watchdog detects WAN drop (3 failed cloud health checks, ping timeout > 3000ms).
- Status changes to **🟡 Edge Autonomous (Offline)**.
- Local API routing redirects internal operations to the local SQLite storage engine:
  - `POST /api/v1/dqms/tokens/issue`: Generates a unique `ClientTokenGuid` (timestamp-ordered UUIDv7) and offline ticket number (e.g. `OFF-A-101`), commits to SQLite, and prints physical ticket.
  - `POST /api/v1/dqms/staff/counter/call`: Reads next token from local SQLite queue, transitions status to `Calling`, broadcasts instantly across LAN via local SignalR to the TV displays and audio chimers.
  - `POST /api/v1/dqms/staff/counter/status`: Updates token lifecycle (`Calling` -> `Active` -> `Completed` / `Forwarded`).
  - **Journaling:** Every offline mutation is appended to `EdgeSyncJournal` with:
    `JournalId`, `ClientTokenGuid`, `EventType`, `PayloadJson`, `LocalTimestampUtc`, `SequenceNumber`.

### 3.3 Mode 3: Reconciling / Hybrid Sync Mode (WAN Restored)
- The Edge Gateway watchdog detects WAN recovery (2 successful cloud health checks).
- Status changes to **🔄 Synchronizing**.
- The `EdgeHybridSyncService` starts reading pending records from `EdgeSyncJournal` in batches of 50.
- Sends batch payload to Cloud: `POST /api/v1/dqms/edge/sync` with Edge Node Authorization Bearer Token.
- Cloud processes batch transactionally inside `PR_IU_ProcessEdgeSyncBatch`:
  - Inserts new tokens with original creation timestamps and links them to the permanent Cloud `TokenTransactionId`.
  - Applies state transitions (`Calling`, `Active`, `Completed`).
  - Resolves any state conflicts using state dominance.
- Cloud returns `SyncBatchResponse`: `{ "batchId": "...", "processedCount": 50, "failedGuids": [] }`.
- Edge Gateway marks journal entries as `Synced = 1`.
- Transition returns to **🟢 Cloud Connected**.

---

## 4. Cryptographic Keying & Conflict Resolution Protocol

### 4.1 UUIDv7 Anti-Collision Guarantee
To eliminate primary key collision between offline edge databases and the multi-tenant cloud database:
- Every token transaction generated anywhere in the ecosystem MUST carry a `ClientTokenGuid` generated via **UUIDv7**:
  - Contains a 48-bit millisecond timestamp in the high bits, ensuring natural chronological B-Tree indexing in SQL Server and MySQL.
  - Contains 74 bits of cryptographically secure randomness, ensuring $0.00000000001\%$ collision probability across distributed branch edge nodes.
- Central database enforces a unique constraint:
  `CREATE UNIQUE NONCLUSTERED INDEX UX_TokenTransaction_ClientTokenGuid ON TokenTransaction(ClientTokenGuid) WHERE ClientTokenGuid IS NOT NULL;`

### 4.2 State Machine Dominance (Conflict Resolution)
If an edge node was disconnected for 3 hours, edge tellers and remote users might both have interacted with the system:
- **Rule 1: Add-Wins (Append Invariant)**: Every ticket issued by a physical kiosk was printed and handed to a living human customer. It is an immutable operational commitment. The cloud will ALWAYS accept and persist offline-issued tokens.
- **Rule 2: State Machine Dominance Hierarchy**:
  $$\text{Completed} (18007) \succ \text{Forwarded} (18008) \succ \text{Active} (18004) \succ \text{Calling} (18003) \succ \text{Waiting} (18002) \succ \text{Queued} (18001)$$
  - If a token is marked `Completed` on the local edge teller counter, it cannot be downgraded back to `Waiting` or `Calling` by an out-of-order sync packet.
- **Rule 3: Cancellation vs Service Conflict**:
  - If a customer canceled the ticket on their mobile PWA while the teller physically served the ticket offline, the physical teller service (`Completed`) wins, and a conflict audit record is logged with flag `CONFLICT_RESOLVED_TELLER_SERVED`.

---

## 5. Database Schema & Migration Script 41 (`41_DQMS_Offline_Edge_Hybrid_Sync.sql`)

### 5.1 Cloud Database Alterations & Tables
1. **Alter `TokenTransaction`**:
   - `ClientTokenGuid UNIQUEIDENTIFIER NULL`
   - `IsOfflineGenerated BIT NOT NULL DEFAULT 0`
   - `EdgeNodeId NVARCHAR(64) NULL`
   - `SyncedAt DATETIME NULL`
   - Unique Index: `UX_TokenTransaction_ClientTokenGuid`
2. **`EdgeNodeRegistration` Table**:
   - `Id INT IDENTITY(1,1) PRIMARY KEY`
   - `NodeId NVARCHAR(64) UNIQUE NOT NULL` (e.g. `EDGE-DXB-CLINIC-01`)
   - `OrganizationId INT NOT NULL`
   - `LocationId INT NOT NULL`
   - `SecretKeyHash NVARCHAR(256) NOT NULL` (HMAC authentication)
   - `IsActive BIT NOT NULL DEFAULT 1`
   - `LastHeartbeatAt DATETIME NULL`
   - `SoftwareVersion NVARCHAR(32) NULL`
   - `CreatedAt DATETIME DEFAULT GETUTCDATE()`
3. **`EdgeSyncAuditLog` Table**:
   - `Id BIGINT IDENTITY(1,1) PRIMARY KEY`
   - `BatchId NVARCHAR(64) NOT NULL`
   - `EdgeNodeId NVARCHAR(64) NOT NULL`
   - `RecordsIngested INT NOT NULL`
   - `ConflictsResolved INT NOT NULL DEFAULT 0`
   - `DurationMs INT NOT NULL`
   - `Status NVARCHAR(32) NOT NULL`
   - `CreatedDate DATETIME DEFAULT GETUTCDATE()`
4. **Stored Procedures**:
   - `PR_IU_EdgeNodeRegistration`
   - `PR_S_EdgeNodes`
   - `PR_IU_ProcessEdgeSyncBatch` (Bulk TVP / JSON batch ingestion inside a single SQL transaction)

### 5.2 Local Branch Edge SQLite Schema (`dqms_edge.db`)
- `EdgeConfigCache`: Key-value configuration mirror with timestamp.
- `EdgeTokenTransaction`: Mirrors `TokenTransaction` with `ClientTokenGuid TEXT PRIMARY KEY`.
- `EdgeSyncJournal`:
  - `JournalId INTEGER PRIMARY KEY AUTOINCREMENT`
  - `ClientTokenGuid TEXT NOT NULL`
  - `EventType TEXT NOT NULL` (`token.issued`, `token.called`, `token.completed`, etc.)
  - `PayloadJson TEXT NOT NULL`
  - `LocalTimestampUtc TEXT NOT NULL`
  - `IsSynced INTEGER NOT NULL DEFAULT 0`
  - `SyncedAt TEXT NULL`

---

## 6. Implementation Deliverables across Backend & Frontend

### 6.1 Backend (`DNAQMSAPI`)
- **Shared Models**: `EdgeSyncBatchDto`, `EdgeSyncItemDto`, `EdgeSyncResultDto`, `EdgeNodeRegistrationDto` in `AntiGravity.Enterprise.Shared.Core`.
- **Controller**: `EdgeSyncController.cs` exposing:
  - `POST /api/v1/dqms/edge/register` — Authorize and register a local edge appliance.
  - `POST /api/v1/dqms/edge/heartbeat` — Periodic telemetry and configuration version check.
  - `POST /api/v1/dqms/edge/sync` — Bulk batch delta reconciliation endpoint.
- **Service Layer**:
  - `IEdgeSyncService.cs` and `EdgeSyncService.cs` inside `DNAQMSAPI.Infrastructure`.
  - Transactional bulk reconciliation executing `PR_IU_ProcessEdgeSyncBatch`.

### 6.2 Edge Daemon Project (`DNAQMSAPI.Edge`)
- Self-contained, lightweight C# .NET 8 Worker/Kestrel service that can run on Windows as a Service or in Docker.
- Hosts local `EdgeHub` (SignalR) on LAN port 5000.
- Implements `LocalTokenRepository` using `Microsoft.Data.Sqlite`.
- Implements `EdgeSyncWorker` background service for WAN monitoring and auto-sync.

### 6.3 Frontend (Flutter Riverpod Admin & Client Apps)
- **Edge-Aware Network Interceptor (`edge_aware_dio_interceptor.dart`)**:
  - Automatically fails over to local Edge Gateway IP when Cloud SaaS is unreachable.
- **Live Status Header Banner (`EdgeResilienceBanner`)**:
  - Shows connectivity state:
    - 🟢 `Cloud Connected (Global SaaS)`
    - 🟡 `Edge Autonomous (Local Offline Resilience Active)`
    - 🔄 `Synchronizing 42 Offline Transactions...`
- **Admin Edge Console Screen (`edge_nodes_view.dart`)**:
  - Visual edge appliance management: view connected branch nodes, sync latency, offline queue backlog, and manual reconciliation triggers.
  - Route `/admin/edge-nodes` integrated into `ShellRoute`, `navigation_menu_provider.dart` (`_fallbackMenus`), and DB `navigationmenu`.

---

## 7. Verification & Edge Cases

| Test Case | Scenario Description | Expected Invariant Behavior |
|---|---|---|
| **TC-EDGE-01** | Instant WAN Drop during Kiosk ticket print | Kiosk continues printing without latency; assigns offline sequence `OFF-A-001`. |
| **TC-EDGE-02** | Multi-Teller Offline Coordination | Teller 1 calls `OFF-A-001`, Teller 2 calls `OFF-A-002` over LAN. No collision. |
| **TC-EDGE-03** | Local TV Screen & Chime playback | TV Screen receives SignalR broadcast from local Edge Daemon over LAN without internet. |
| **TC-EDGE-04** | Duplicate Batch Replay (Idempotency) | Replaying the same sync packet twice returns success without creating duplicate rows. |
| **TC-EDGE-05** | Split-Brain Conflict Resolution | Physical teller `Completed` state overrides PWA `Canceled` state; conflict logged in audit table. |
| **TC-EDGE-06** | Clock Skew Tolerance | Edge node with $\pm 15$ min clock drift uses UUIDv7 monotonic sequence to maintain order. |

---

## 8. Rollout & Migration Strategy

1. **Step 1: Database Migration**: Run Script `41_DQMS_Offline_Edge_Hybrid_Sync.sql` on Cloud databases.
2. **Step 2: Core Contracts & Controller**: Deploy `EdgeSyncController` and `EdgeSyncService` to Cloud API.
3. **Step 3: Edge Daemon Package**: Compile standalone executable `dqms-edge.exe` / Docker container.
4. **Step 4: Frontend Network Failover**: Inject `EdgeAwareDioInterceptor` and status banner into Flutter frontend.
5. **Step 5: Admin Edge Console**: Register `/admin/edge-nodes` screen in admin sidebar and permissions matrix.
