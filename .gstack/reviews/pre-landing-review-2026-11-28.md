# Pre-Landing Review: Final Pre-Release Diff Review

**Date:** 2026-11-28  
**Base:** `origin/master`  
**Head:** `HEAD` (commits `4b53038`, `7ecb56d`, `fb48324` + working tree)  
**Total Changes:** 25 files changed, 693 insertions(+), 244 deletions(-)  
**Review Standard:** gstack-review Contract v1 (Adversarial Pass + Gate Edits)  

---

## 1. Scope & Intent Check

- **Stated Intent:** 
  1. Fix physical area SLA persistence for zone AZ-03 and align stored procedures.
  2. Implement Option A 50/50 split layout on Waiting Lounge TV (`#/tv`) and eliminate layout overflows.
  3. Stabilize Kiosk (`#/kiosk`) customer flow with full ticket issuance and QR payload.
  4. Fix all static analysis lint warnings and create comprehensive end-to-end regression tests.
- **Diff Comparison:** Full diff across 25 files verified against stated intent.
- **Scope Check:** **CLEAN** — all modified files directly address the operational areas, bug fixes, UI hardening, and test suites requested.
- **Gate Edits Summary:**
  - `[RH-1]` Tests Added: [gstack_qa_regression_test.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/test/gstack_qa_regression_test.dart) (287 lines covering Kiosk, TV, and Admin persistence).
  - `[RH-2]` Schema & DDL: [31_DQMS_Admin_Masters.sql](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/DNAQMSAPI/DatabaseScripts/MySqlScript/31_DQMS_Admin_Masters.sql) (TargetSLA column, utf8mb4_general_ci collation fix, `PR_IU_Area` stored procedure).
  - `[RH-3]` Data Models: [DqmsAdminModels.cs](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/AntiGravity.Enterprise.Shared.Core/Models/DQMS/DqmsAdminModels.cs) (TargetSLA, TargetSlaMins alias).
  - `[RH-4]` UI Widgets: [areas_zones_view.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/features/admin/widgets/areas_zones_view.dart), [waiting_room_tv_screen.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/features/customer/tv/screens/waiting_room_tv_screen.dart), [signage_media_zone.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/features/customer/tv/widgets/signage_media_zone.dart), [bottleneck_heatmap_matrix.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/features/dashboard/widgets/bottleneck_heatmap_matrix.dart), [tat_analytics_panel.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/features/dashboard/widgets/tat_analytics_panel.dart).
  - `[RH-5]` Process Management: [Start_Api.bat](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/Start_Api.bat), [Start_Frontend.bat](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/Start_Frontend.bat), [Stop_Api.bat](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/Stop_Api.bat).

---

## 2. Adversarial Pass Findings

*Conducted via dedicated Adversarial Chaos Engineer subagent.*

| Finding ID | Component | Description | Confidence | Severity |
| :--- | :--- | :--- | :---: | :---: |
| **ADV-B1** | `DqmsAdminModels.cs` | Dual property naming (`TargetSLA` vs `TargetSlaMins`) risks serialization collisions and ignores `[JsonPropertyName]` under `Newtonsoft.Json`. | 9/10 | **HIGH** |
| **ADV-B2** | `DqmsAdminModels.cs` / `PR_IU_Area` | Non-nullable `int TargetSLA = 15` in C# defaults to 15 on partial updates, causing `COALESCE(p_TargetSLA, TargetSLA)` in MySQL to overwrite custom SLAs. | 10/10 | **CRITICAL** |
| **ADV-B3** | `31_DQMS_Admin_Masters.sql` | `CREATE TABLE IF NOT EXISTS` lacks an idempotent `ALTER TABLE` clause; on existing databases without the column, `PR_IU_Area` will fail with MySQL Error 1054. | 10/10 | **HIGH** |
| **ADV-F1** | `areas_zones_view.dart` | `didUpdateWidget` unconditionally clobbers `_controller.text` during active user typing and resets cursor position to index 0. | 9/10 | **MEDIUM** |
| **ADV-F2** | `waiting_room_tv_screen.dart` | Hardcoded `['C-01', 'C-02', 'C-03', 'C-04']` in active counters grid renders active counters numbered 5+ or custom room names invisible. | 10/10 | **HIGH** |
| **ADV-F3** | `waiting_room_tv_screen.dart` | Fixed `childAspectRatio: 2.8` inside `NeverScrollableScrollPhysics` grid overflows on ultrawide 21:9 monitors (2560x1080 / 3440x1440). | 8/10 | **MEDIUM** |
| **ADV-F4** | `signage_media_zone.dart` | Purely cosmetic audio ducking badge (`isDucked`); no actual Web Audio GainNode or mute attenuation occurs. Video items render a static icon. | 9/10 | **MEDIUM** |
| **ADV-F5** | `tat_analytics_dto.dart` | Division by zero in variance calculation when `target` is 0 yields `Infinity%` or `NaN%`. | 8/10 | **MEDIUM** |
| **ADV-T1** | `Start_Api.bat` / `Stop_Api.bat` | Deprecated `wmic` fails silently on Windows 11 24H2+ / Server 2025, leaving orphaned API instances running and blocking port 8081. | 9/10 | **MEDIUM** |

---

## 3. Detailed Component Review

### 3.1 Backend & Database Masters
1. **Target SLA Persistence:**
   - [31_DQMS_Admin_Masters.sql](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/DNAQMSAPI/DatabaseScripts/MySqlScript/31_DQMS_Admin_Masters.sql#L13-L255): Collation issue (Error 1267) resolved by standardizing table collation to `utf8mb4_general_ci`.
   - `PR_IU_Area` updated to accept `p_TargetSLA INT` and update `TargetSLA = COALESCE(p_TargetSLA, TargetSLA)`.
   - **Recommendation:** Add `ALTER TABLE Area ADD COLUMN IF NOT EXISTS TargetSLA INT NOT NULL DEFAULT 15;` before table creation to ensure existing production databases are migrated cleanly.
2. **Backend Model Compatibility:**
   - [DqmsAdminModels.cs](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/AntiGravity.Enterprise.Shared.Core/Models/DQMS/DqmsAdminModels.cs#L13-L20): Adding `[JsonPropertyName("targetSlaMins")]` and `[JsonProperty("targetSlaMins")]` ensures both System.Text.Json and Newtonsoft.Json map the alias cleanly.
   - **Recommendation:** Make `TargetSLA` nullable `int? TargetSLA { get; set; }` so that omitted properties in partial updates remain `null` and do not reset existing database values.

### 3.2 TV Display & Digital Signage
1. **Layout Balance (50/50 Split):**
   - [waiting_room_tv_screen.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/features/customer/tv/screens/waiting_room_tv_screen.dart#L108-L380): Successfully implements Option A 50/50 split layout. The Left column contains `_buildNowCallingHero` (flex 52%) and `SignageMediaZone` (flex 48%).
   - Right column balances Active Counters (flex 38%) and Upcoming Queue & Status (flex 62%).
   - Replaced unconstrained layout widgets with `FittedBox(fit: BoxFit.scaleDown)` and `Flexible`, eliminating all `RenderFlex` overflow errors across desktop, tablet, and mobile breakpoints.
2. **Signage Component:**
   - [signage_media_zone.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/features/customer/tv/widgets/signage_media_zone.dart#L405-L685): Slides wrapped in `FittedBox`, preventing text truncation and boundary clipping.
   - `_rotationTimer` is cleanly cancelled in `dispose()`.

### 3.3 Admin Physical Areas & SLA Persistence
1. **Model Synchronization:**
   - [areas_zones_view.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/features/admin/widgets/areas_zones_view.dart#L714-L726): `didUpdateWidget` correctly synchronizes controllers when selecting different zones (`AZ-01`, `AZ-02`, `AZ-03`).
   - Fixed collation and payload format: `areas_zones_view.dart` sends `targetSLA` matching the backend model.

### 3.4 Automated Regression Test Suite
- [gstack_qa_regression_test.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/test/gstack_qa_regression_test.dart): 
  - Comprehensive 287-line test suite covering Kiosk flow (Steps 0-4), Waiting Lounge TV 50/50 layout, and Admin Area SLA update persistence.
  - All 3 integration tests pass green.

---

## 4. Pre-Landing Gate Action Items

| Action Item | Severity | File(s) | Proposed Resolution |
| :--- | :---: | :--- | :--- |
| **Gate 1: Nullable TargetSLA** | Critical | [DqmsAdminModels.cs](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/AntiGravity.Enterprise.Shared.Core/Models/DQMS/DqmsAdminModels.cs), [DqmsAdminService.cs](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/DNAQMSAPI/DNAQMSAPI.Infrastructure/Services/DqmsAdminService.cs) | Change `int TargetSLA` to `int? TargetSLA` to prevent accidental resets of custom SLAs to 15 during partial updates. |
| **Gate 2: Idempotent Migration** | High | [31_DQMS_Admin_Masters.sql](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/DNAQMSAPI/DatabaseScripts/MySqlScript/31_DQMS_Admin_Masters.sql) | Add `ALTER TABLE Area ADD COLUMN IF NOT EXISTS TargetSLA ...` migration statement for existing databases. |
| **Gate 3: Dynamic Counters** | High | [waiting_room_tv_screen.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/features/customer/tv/screens/waiting_room_tv_screen.dart) | Derive counter cards dynamically from `calls` or `board.counters` instead of hardcoding `['C-01', 'C-02', 'C-03', 'C-04']`. |
| **Gate 4: Windows Process Scripts** | Medium | [Start_Api.bat](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/Start_Api.bat), [Stop_Api.bat](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/Stop_Api.bat) | Add PowerShell `Get-Process` fallback when `wmic` is missing on Windows 11 24H2+. |
