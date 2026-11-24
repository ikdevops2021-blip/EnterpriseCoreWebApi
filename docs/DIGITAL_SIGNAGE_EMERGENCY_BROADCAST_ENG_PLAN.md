# Technical Architecture & Engineering Plan: Digital Signage Campaigns & Emergency Broadcast Engine

**Document Version:** 1.0.0  
**Target System:** DQMS Enterprise (.NET 8 Core Web API + Flutter Multiplatform Frontend + Dual DB MSSQL/MySQL + Real-Time Display Hub)  
**Feature Scope:** Multi-Zone Waiting Room 4K Display, Rich Media Signage Playlists (Video/Images), Time-Window Scheduling, Audio Ducking, Real-Time Emergency Broadcast Overlay (Code Red/Blue/Evacuation), and Instant De-escalation Protocol.

---

## 1. Executive Summary & Problem Space

### 1.1 The Operational Need
Waiting lounge TV monitors are the most critical visual anchor in healthcare facilities, banks, service centers, and municipal hubs. Currently, the DQMS Waiting Room TV Display (`WaitingRoomTvScreen`) renders:
1. A **NOW CALLING** hero token capsule (left).
2. A **PREVIOUS CALLS** matrix (right).
3. A single, static bottom text marquee ticker bar.

However, two enterprise requirements remain unaddressed:
1. **Commercial & Educational Digital Signage**: Healthcare organizations and commercial enterprises require rich media (educational videos, promotional banners, health advisories) running alongside or alternating with queue announcements to reduce perceived wait times and communicate vital public health notices.
2. **Life-Safety Emergency Public Broadcast**: In the event of a fire (Code Red), cardiac arrest (Code Blue), severe weather alert, or active security lockdown, administrators must possess an instantaneous, high-priority "panic broadcast" override that immediately commands all waiting room displays, silences commercial audio, sounds emergency sirens, and flashes unambiguous evacuation or safety instructions.

---

## 2. Architecture: "Design Twice" Structural Evaluation

### Shape 1: Monolithic Video Embed inside Queue Screen (Rejected)
- Directly embed a full-screen or half-screen Flutter `video_player` controller inside `WaitingRoomTvScreen`.
- *Why Rejected*:
  - **Memory & GPU Leaks**: Running high-bitrate video decoding inside the same widget tree as real-time WebSocket queue updates leads to frame drops and memory leaks on low-powered Android TV sticks and Raspberry Pi display appliances.
  - **Single Point of Failure**: A corrupted video stream or network buffer stall hangs the entire Flutter render thread, freezing the ticket display and causing lobby chaos.
  - **Rigid Layout**: Hardcodes media placement, preventing organizations from toggling between Split Screen (Queue 60% / Media 40%), Picture-in-Picture (PIP), and Fullscreen Promotional Intermission.

### Shape 2: Decoupled Multi-Zone Display Compositor with Priority Interrupt Layer (Approved)
- The display screen is partitioned into three decoupled rendering zones managed by independent state providers:
  1. **Primary Queue Zone**: Renders now-calling tokens, counter numbers, and call history with smooth responsive auto-scaling.
  2. **Signage Media Zone**: An isolated media viewport supporting rotating playlists (H.264/MP4 video streams, high-res image slides, HTML5 widgets) with automated pre-caching, smooth cross-fades, and audio ducking whenever a queue voice chime triggers.
  3. **Emergency Broadcast Interrupt Layer**: A top-level visual and auditory overlay positioned at the highest Z-index stack. It sleeps at zero CPU cost until an `EmergencyBroadcastEvent` arrives via SignalR/WebSocket, whereupon it instantly mutes media, triggers a pulsating strobe border, sounds audio sirens, and renders mission-critical instructions across all screens.

```
+---------------------------------------------------------------------------------------------------------+
|                                    WAITING ROOM TV DISPLAY (4K SCREEN)                                  |
|                                                                                                         |
|  +---------------------------------------------------------------------------------------------------+  |
|  | [ZONE 0] HEADER BAR: Brand Logo • Facility Name • Digital Clock • Active Language Selector        |  |
|  +---------------------------------------------------------------------------------------------------+  |
|                                                                                                         |
|  +-------------------------------------------------+  +----------------------------------------------+  |
|  | [ZONE 1] PRIMARY QUEUE DISPLAY (60% Width)      |  | [ZONE 2] DIGITAL SIGNAGE MEDIA (40% Width)   |  |
|  |                                                 |  |                                              |  |
|  |  +-------------------------------------------+  |  |  +----------------------------------------+  |  |
|  |  | NOW CALLING HERO: Token A-101 -> Counter 4 |  |  |  | Video / High-Res Image Carousel      |  |  |
|  |  +-------------------------------------------+  |  |  | (1080p MP4, WebM, Corporate Slide)     |  |  |
|  |  | PREVIOUS CALLS MATRIX:                    |  |  |  | Auto-loop with audio ducking on chime  |  |  |
|  |  | B-204 -> C-02 | C-109 -> C-05             |  |  |  +----------------------------------------+  |  |
|  |  +-------------------------------------------+  |  | Scheduled Playlist: 09:00 - 17:00 M-F        |  |
|  +-------------------------------------------------+  +----------------------------------------------+  |
|                                                                                                         |
|  +---------------------------------------------------------------------------------------------------+  |
|  | [ZONE 3] DYNAMIC TICKER: Multi-item scrolling announcements • Weather • RSS • Custom Notices       |  |
|  +---------------------------------------------------------------------------------------------------+  |
|                                                                                                         |
|  =====================================================================================================  |
|  [ZONE 4: PRIORITY OVERLAY] EMERGENCY BROADCAST INTERRUPT (Z-INDEX: 9999)                               |
|  * Strobe Flashing Banner: [ CODE RED - FIRE EVACUATION IN PROGRESS ]                                 |
|  * Audio Siren Override: Continuous evacuation wail (media & queue chimes suppressed)                   |
|  * Clear Exit Directives: "Evacuate via Stairwell B. Do not use elevators."                            |
+---------------------------------------------------------------------------------------------------------+
```

---

## 3. Database Schema & Migration Specification (Script 42)

To maintain database parity across **MSSQL** and **MySQL 8.0**, Script 42 introduces the following normalized relational entities:

### 3.1 `SignageCampaign`
Defines high-level promotional or informational campaigns:
- `Id` (INT, PK, Identity)
- `OrganizationId` (INT, FK)
- `CampaignName` (NVARCHAR(150), NOT NULL)
- `CampaignType` (INT, NOT NULL DEFAULT 1) -- 1=Promotional, 2=Health Advisory, 3=Corporate
- `Priority` (INT NOT NULL DEFAULT 5) -- 1 (Low) to 10 (Highest)
- `StartDate` (DATETIME NOT NULL)
- `EndDate` (DATETIME NOT NULL)
- `DailyStartTime` (TIME NULL) -- e.g. '08:00:00'
- `DailyEndTime` (TIME NULL) -- e.g. '18:00:00'
- `DaysOfWeek` (NVARCHAR(20) NOT NULL DEFAULT '1,2,3,4,5,6,7')
- `IsActive` (BIT NOT NULL DEFAULT 1)
- `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`, `IsDeleted`

### 3.2 `SignageMediaItem`
Represents individual media slides or video clips within a campaign playlist:
- `Id` (INT, PK, Identity)
- `CampaignId` (INT, FK to SignageCampaign, ON DELETE CASCADE)
- `MediaType` (INT NOT NULL) -- 1=Image (JPG/PNG/WebP), 2=Video (MP4/HLS), 3=HTML5 Widget, 4=Ticker Text
- `MediaUrl` (NVARCHAR(500) NOT NULL)
- `LocalCachePath` (NVARCHAR(500) NULL)
- `Title` (NVARCHAR(150) NOT NULL)
- `DurationSeconds` (INT NOT NULL DEFAULT 15) -- Playback dwell time before next slide
- `DisplayOrder` (INT NOT NULL DEFAULT 1)
- `MuteAudio` (BIT NOT NULL DEFAULT 1) -- Default muted to preserve lobby tranquility
- `IsActive` (BIT NOT NULL DEFAULT 1)

### 3.3 `SignageCampaignMapping`
Associates campaigns with physical organizations, locations, and service areas:
- `Id` (INT, PK, Identity)
- `CampaignId` (INT, FK)
- `OrganizationId` (INT NOT NULL)
- `LocationId` (INT NOT NULL)
- `AreaId` (INT NULL) -- NULL applies to all areas within the location
- `TemplateId` (INT NULL) -- NULL applies to all display boards
- `IsActive` (BIT NOT NULL DEFAULT 1)

### 3.4 `EmergencyBroadcast`
Captures active and historical emergency broadcast events:
- `Id` (INT, PK, Identity)
- `OrganizationId` (INT NOT NULL)
- `LocationId` (INT NULL) -- NULL = Tenant-wide broadcast
- `AreaId` (INT NULL)
- `BroadcastCode` (NVARCHAR(50) NOT NULL) -- 'CODE_RED', 'CODE_BLUE', 'EVACUATION', 'WEATHER', 'CUSTOM'
- `Title` (NVARCHAR(150) NOT NULL)
- `MessageText` (NVARCHAR(1000) NOT NULL)
- `Severity` (INT NOT NULL DEFAULT 3) -- 1=Info (Cyan), 2=Warning (Amber), 3=Critical (Red)
- `AudioSirenType` (INT NOT NULL DEFAULT 1) -- 0=Silent, 1=Pulse Chime, 2=Continuous Siren, 3=Voice Alert
- `FlashColorHex` (NVARCHAR(10) NOT NULL DEFAULT '#FF1744')
- `IsActive` (BIT NOT NULL DEFAULT 1)
- `TriggeredByUserId` (INT NOT NULL)
- `TriggeredAt` (DATETIME NOT NULL DEFAULT GETDATE())
- `DismissedByUserId` (INT NULL)
- `DismissedAt` (DATETIME NULL)

### 3.5 Stored Procedures
1. `PR_IU_SignageCampaign`: Insert or update campaign details and playlist items.
2. `PR_S_ActiveSignagePlaylist`: Returns valid active media playlist for a given `OrganizationId`, `LocationId`, and `AreaId`, evaluated against server clock `GETDATE()` and current day-of-week.
3. `PR_IU_EmergencyBroadcast`: Triggers an emergency broadcast or records dismissal.
4. `PR_S_ActiveEmergencyBroadcast`: Fetches the currently active emergency broadcast for display board sync.

---

## 4. Backend Architecture (.NET 8 Clean Architecture)

### 4.1 Domain & DTO Contracts (`AntiGravity.Enterprise.Shared.Core`)
- `SignageCampaignDto`, `SignageMediaItemDto`, `SaveSignageCampaignRequestDto`, `SignagePlaylistResponseDto`.
- `EmergencyBroadcastDto`, `TriggerEmergencyRequestDto`, `DismissEmergencyRequestDto`.

### 4.2 Application Interfaces
- `ISignageService`: Handles playlist resolution, campaign scheduling validation, and media item management.
- `IEmergencyBroadcastService`: Handles emergency activation, audit logging, and SignalR dispatch.

### 4.3 Real-Time SignalR Broadcast Hub (`WaitingRoomHub`)
Exposes bi-directional push notifications for display terminals:
- `BroadcastEmergencyAlert(EmergencyBroadcastDto alert)`: Pushes instantaneous fullscreen alert to all connected display sockets within the targeted Organization/Location.
- `BroadcastEmergencyDismissal(int broadcastId)`: Notifies screens to dismiss the strobe overlay and resume standard queue and media playback.
- `BroadcastSignageUpdate(int locationId)`: Tells displays to refresh their cached playlist when an admin modifies campaign assets.

### 4.4 REST Controllers
- `SignageController` (`/api/v1/Signage`):
  - `GET /campaigns`: List all campaigns for organization.
  - `POST /campaigns`: Create or update campaign with media items.
  - `DELETE /campaigns/{id}`: Soft delete campaign.
  - `GET /playlist`: Public endpoint consumed by TV displays to load active media items.
- `EmergencyBroadcastController` (`/api/v1/EmergencyBroadcast`):
  - `POST /trigger`: Trigger emergency (requires authorized staff/admin token).
  - `POST /dismiss`: Dismiss active emergency.
  - `GET /active`: Check active emergency status for a location.
  - `GET /history`: Audit trail of past emergency broadcasts.

---

## 5. Frontend Architecture (Flutter Riverpod)

### 5.1 Real-Time TV Display (`WaitingRoomTvScreen`)
1. **Dynamic Layout Switching**:
   - `SignageLayoutMode.splitRight` (Queue 60% Left, Media 40% Right)
   - `SignageLayoutMode.queueHero` (Full Queue layout with floating corner media widget)
   - `SignageLayoutMode.pip` (Picture-in-Picture)
2. **Audio Ducking System**:
   - Background promotional videos run at configured volume (or muted).
   - When a token announcement occurs (`audioChimeService.playTokenChime()`), the media player volume is immediately ducked to 0%, the token voice/chime plays, and volume smoothly fades back up over 800ms.
3. **Emergency Broadcast Overlay (`EmergencyBroadcastBanner`)**:
   - Animated top-level container with alternating red/amber strobe border (`AnimationController` pulsing at 2 Hz).
   - Prominent flashing icon (`Icons.warning_amber_rounded` or `Icons.local_hospital_rounded`).
   - High-contrast emergency banner typography with emergency directive instructions.
   - Built-in audio tone generator playing the selected alert chime.

### 5.2 Admin Console (`SignageCampaignsView` & `EmergencyConsoleModal`)
1. **Signage Campaigns View (`/admin/signage-campaigns`)**:
   - Master-detail campaign list with status chips (🟢 Active, 🟡 Scheduled, ⚪ Inactive).
   - Playlist item manager: Add image URLs or video streams, configure dwell duration (15s default), preview thumbnails.
   - Date range and daily active time-slot pickers.
2. **Emergency Broadcast Panel**:
   - Prominent red action button in Admin AppBar: **"EMERGENCY BROADCAST"**.
   - Quick-action templates:
     - 🚨 **Code Red (Fire / Evacuation)**
     - 🏥 **Code Blue (Medical Emergency / Cardiac Arrest)**
     - 🌪️ **Severe Weather Alert**
     - 🔒 **Security Lockdown**
   - Target location selector (All Branches vs. Specific Building/Area).
   - Instant live confirmation with PIN verification to prevent accidental triggers.
   - Active Emergency Banner in Admin header with **"CANCEL BROADCAST / ALL CLEAR"** button.

---

## 6. Key Edge Cases & Failure Modes

| Edge Case | Failure Mode | Architectural Remedy |
|---|---|---|
| **Media Stream Network Failure** | Video fails to buffer or external URL is blocked by firewall | Displays catch media errors gracefully, log warning, and fall back instantly to cached promotional images or standard queue view. |
| **Emergency Broadcast Race Condition** | Two administrators trigger conflicting emergencies simultaneously | Database transaction in `PR_IU_EmergencyBroadcast` enforces single active emergency per location; the higher severity level takes dominance. |
| **Audio Collision / Cacophony** | Commercial promo audio, queue voice synthesizer, and emergency sirens sound simultaneously | Audio Arbiter enforces strict hierarchical audio mute: $\text{Emergency Siren} \succ \text{Queue Voice Chime} \succ \text{Signage Media}$. |
| **TV Display Refresh / Reboot during Emergency** | TV restarts while an emergency is ongoing | On initial connection, `WaitingRoomTvScreen` queries `PR_S_ActiveEmergencyBroadcast`; if active, screen immediately mounts the emergency overlay before loading queue data. |

---

## 7. Compliance with Project Rules
- **Database Seeding**: Added `/admin/signage-campaigns` entry to `NavigationMenu` in DB migration script 42.
- **Frontend Fallback**: Added fallback route `/admin/signage-campaigns` inside `navigation_menu_provider.dart`.
- **Clean Architecture Boundaries**: Preserved separation across Domain, Application, Infrastructure, API, and Flutter features.
