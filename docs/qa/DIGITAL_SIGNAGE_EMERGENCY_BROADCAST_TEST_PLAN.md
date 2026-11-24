# QA Test Plan: Digital Signage Campaigns & Emergency Broadcast Engine

**Document Version:** 1.0.0  
**Target Feature:** Multi-Zone Digital Signage Playlists, Time-Slot Scheduling, Audio Ducking, and High-Priority Emergency Broadcast Overlays.

---

## 1. Test Architecture Matrix

```
+---------------------------------------------------------------------------------------------------------+
|                                    QA TEST SUITE TAXONOMY & VERIFICATION                                |
|                                                                                                         |
|   +------------------------------------+       +----------------------------------------------------+   |
|   |         Database Tier              |       |                    Backend API                     |   |
|   |   (Scripts 42 MSSQL & MySQL)       |       |              (.NET 8 Web API / Dapper)             |   |
|   |                                    |       |                                                    |   |
|   | * Table constraints & cascades     |       | * ISignageService CRUD validation                  |   |
|   | * PR_S_ActiveSignagePlaylist clock |       | * IEmergencyBroadcastService trigger & dismiss     |   |
|   | * PR_IU_EmergencyBroadcast locks   |       | * SignalR Hub client notification dispatch         |   |
|   +-----------------+------------------+       +-------------------------+--------------------------+   |
|                     |                                                    |                              |
|                     +--------------------------+-------------------------+                              |
|                                                |                                                        |
|                                                v                                                        |
|                       +------------------------------------------------+                                |
|                       |            Frontend Riverpod & UI              |                                |
|                       |               (Flutter Desktop / TV)           |                                |
|                       |                                                |                                |
|                       | * Media Carousel rotation & dwell time (15s)   |                                |
|                       | * Audio Ducking Arbiter (Mute on Token Chime)  |                                |
|                       | * Emergency Broadcast Overlay (Z-index 9999)   |                                |
|                       | * Strobe animation & Alarm sound generation    |                                |
|                       | * Admin Signage & Emergency trigger consoles   |                                |
|                       +------------------------------------------------+                                |
+---------------------------------------------------------------------------------------------------------+
```

---

## 2. Test Cases Specification

### 2.1 Database & Stored Procedure Verifications

| Test ID | Test Case | Target | Expected Behavior |
|---|---|---|---|
| **DB-SGN-01** | Table Creation & Cascade Deletes | `SignageCampaign`, `SignageMediaItem` | Deleting a `SignageCampaign` automatically cascades delete to its child `SignageMediaItem` records. |
| **DB-SGN-02** | Time-Slot Playlist Filtering | `PR_S_ActiveSignagePlaylist` | Stored procedure filters out campaigns where current time is outside `DailyStartTime` and `DailyEndTime`, or current day-of-week is not in `DaysOfWeek`. |
| **DB-EMG-01** | Emergency Broadcast Activation | `PR_IU_EmergencyBroadcast` | Inserting a new emergency sets `IsActive = 1`, records `TriggeredByUserId`, and returns the generated `BroadcastId`. |
| **DB-EMG-02** | Emergency Broadcast Dismissal | `PR_IU_EmergencyBroadcast` | Dismissing the emergency sets `IsActive = 0` and stamps `DismissedAt = GETDATE()`. |
| **DB-EMG-03** | Active Emergency Resolution | `PR_S_ActiveEmergencyBroadcast` | Returns the latest active emergency for the target Location/Area. If tenant-wide emergency exists (`LocationId IS NULL`), it overrides local areas. |

---

### 2.2 Backend Application & Service Tests

| Test ID | Test Case | Component | Verification Criteria |
|---|---|---|---|
| **BE-SGN-01** | Campaign Validation | `SignageService.SaveCampaignAsync` | Rejects campaigns with `EndDate < StartDate` or invalid time intervals. |
| **BE-SGN-02** | Playlist Assembly | `SignageService.GetActivePlaylistAsync` | Returns ordered list of active media items with correct duration, URL, and mute status. |
| **BE-EMG-01** | Emergency Trigger & Push | `EmergencyBroadcastService.TriggerAsync` | Saves record to DB and broadcasts `ReceiveEmergencyBroadcast` event via SignalR `WaitingRoomHub` to targeted display clients. |
| **BE-EMG-02** | Emergency Dismissal Push | `EmergencyBroadcastService.DismissAsync` | Dispatches `ReceiveEmergencyClear` to all connected display sockets. |
| **BE-SEC-01** | Role-Based Authorization | `EmergencyBroadcastController` | Non-admin/unauthorized staff tokens receive `403 Forbidden` when attempting to trigger emergency broadcasts. |

---

### 2.3 Frontend Widget & Display Tests

| Test ID | Test Case | Component | Verification Criteria |
|---|---|---|---|
| **FE-TV-01** | Split Layout Rendering | `WaitingRoomTvScreen` | Renders Queue Hero (Left) and Signage Media Zone (Right) simultaneously without layout overflow in 1080p and 4K viewports. |
| **FE-TV-02** | Media Playlist Carousel | `SignageMediaZone` | Automatically advances to next slide after `DurationSeconds` elapses. |
| **FE-AUD-01** | Audio Ducking Hierarchy | `AudioArbiter` | Background media audio is muted (0.0 volume) when token chime sounds, restoring smoothly to default volume after 800ms. |
| **FE-EMG-01** | Emergency Overlay Activation | `EmergencyBroadcastOverlay` | Upon receiving emergency state, displays fullscreen pulsing banner, alarm icon, and siren audio while disabling queue calling animations. |
| **FE-EMG-02** | Emergency Deactivation | `EmergencyBroadcastOverlay` | Upon dismissal event, smoothly fades out overlay and restores standard queue and playlist operations. |
| **FE-ADM-01** | Admin Navigation Compliance | `navigation_menu_provider.dart` | Route `/admin/signage-campaigns` exists in fallback menu and opens `SignageCampaignsView`. |
| **FE-ADM-02** | Emergency Modal Safety PIN | `EmergencyConsoleModal` | Requires confirmation before triggering live emergency broadcast across public displays. |

---

## 3. Automated Test Suite Targets
- `DNAQMSAPI.UnitTests`: Unit tests for `SignageService` and `EmergencyBroadcastService`.
- `dqms_frontend/test/digital_signage_emergency_test.dart`: 
  - Model serialization and deserialization (`SignageCampaignDto`, `EmergencyBroadcastDto`).
  - `SignageMediaZone` playlist cycling and duration timer logic.
  - `EmergencyBroadcastOverlay` widget tree mounting and strobe animation state.
  - Navigation provider fallback route verification.
