# OfflineOps

An offline-first iOS app for field service technicians (HVAC, pest control, logistics, etc.) — built to demonstrate production-grade offline sync architecture, not just CRUD over a network.

> Every action works with no signal. The app never blocks on the network, never silently loses data, and never silently overwrites another user's changes.

---

## Why this project exists

Most demo apps assume a reliable network. Field service apps can't — technicians work in basements, rural areas, and dead zones, and the job still has to get done. This project is a focused implementation of the **offline-first** pattern: local-first writes, a sync queue, automatic retry, and explicit conflict resolution.

## Core features

- 📵 **Fully offline operation** — create, update, and complete jobs with zero network connection. Every write goes to local storage first; the network is never on the critical path.
- 🔄 **Automatic background sync** — the moment connectivity returns, the pending-changes queue flushes automatically via `NWPathMonitor`.
- ⚠️ **Real conflict resolution** — if the office (web/dispatcher) edits a job while the technician is offline, the app surfaces both versions side by side instead of silently picking a winner.
- 🔁 **Retry with backoff bookkeeping** — failed syncs (simulated server errors) stay queued and retry automatically, nothing is ever silently dropped.
- 🗺️ **Map overview** — all jobs plotted via MapKit for route planning, built on `CLLocationCoordinate2D`.
- ☀️ **Outdoor-first UI** — high-contrast color language, large type, 56pt+ tap targets, and a persistent connectivity banner — designed for one-hand use in direct sunlight, not an office desk.

## Architecture

```
OfflineOps/
├── App/                 → App entry point
├── Models/              → Job (with embedded sync metadata)
├── Services/
│   ├── LocalJobStore     → Atomic file-based JSON persistence
│   ├── NetworkMonitor    → NWPathMonitor → Combine published state
│   ├── RemoteJobAPI      → Protocol + mock backend (simulates latency,
│   │                       failures, and server-side edits)
│   └── SyncEngine        → The core: local-first mutations,
│                            pending queue, conflict detection
├── ViewModels/           → MVVM — one per screen
└── Views/
    ├── Jobs/             → List, detail, creation flow
    ├── Sync/             → Conflict resolution UI
    ├── Map/              → MapKit job overview
    └── Components/       → SyncStatusBadge, ConnectivityBanner, JobCard
```

### The sync model

Every `Job` carries its own sync metadata:

```swift
var syncStatus: SyncStatus      // synced / pendingCreate / pendingUpdate / pendingDelete / conflict / failed
var localUpdatedAt: Date        // last local mutation
var serverUpdatedAt: Date?      // last known server-confirmed time
var version: Int                // incremented on every local edit
```

`SyncEngine` is the single source of truth:

1. **Local-first mutations** — `createJob`, `updateJob`, `deleteJob` write to the in-memory array and disk immediately, then return. The UI never waits on a network call.
2. **Connectivity-driven sync** — subscribes to `NetworkMonitor.$isConnected` via Combine; the instant the network returns, it attempts to flush every pending job.
3. **Conflict detection** — the mock API compares the client's known server baseline (`serverUpdatedAt`) against the actual server state. If they disagree, it throws `.conflict(serverJob:)` instead of overwriting — the UI then asks the user which version to keep.
4. **Manual sync** — pull-to-refresh calls the same `syncPendingChanges()` path, so there's exactly one sync code path regardless of trigger.

This mirrors real-world patterns used by apps like Notion, Linear, and offline-first logistics tools — local-first writes, explicit conflict surfacing, idempotent retry.

## Tech stack

- **SwiftUI** + **MVVM**
- **Combine** for connectivity-driven reactive sync triggers
- **Network framework** (`NWPathMonitor`) for real connectivity detection
- **MapKit** / **CoreLocation** for job mapping
- **Async/await** throughout the sync and API layer
- File-based JSON persistence (chosen deliberately over CoreData here to keep the sync logic fully transparent and inspectable — see note below)

> **Note on persistence choice:** This project uses atomic file-based JSON storage rather than CoreData. For a focused demo of sync *logic*, this keeps every read/write inspectable as plain JSON and avoids CoreData's own concurrency model competing with the sync engine's. The `LocalStoring` protocol means swapping in a CoreData or SQLite-backed implementation later requires no changes above the storage layer.

## Requirements

- Xcode 16+
- iOS 17+
- No external dependencies — pure SwiftUI + Apple frameworks

## Running the project

1. Open `OfflineOps.xcodeproj` in Xcode
2. Build and run on a simulator or device (iOS 17+)
3. To test offline behavior: toggle Airplane Mode (device) or use Xcode's Network Link Conditioner / simulator network condition tools
4. The app ships with sample jobs in varying sync states (`synced`, `pendingUpdate`, `pendingCreate`, `failed`) so the UI states are visible on first launch without any setup

### Demoing the conflict-resolution flow

The mock backend exposes a test hook to simulate a dispatcher editing a job while the technician is offline:

```swift
mockAPI.simulateServerSideEdit(jobID: someJob.id, newTitle: "Reassigned — Urgent")
```

Trigger this while a job has local pending changes, then bring the network back online to see the conflict sheet.

## What I'd build next

- CoreData-backed persistence for larger job histories
- Photo capture + offline-queued upload (camera was in scope for the original brief)
- Background URLSession tasks so sync continues even if the app is suspended
- Unit tests for `SyncEngine`'s conflict and retry paths

---

Built as a portfolio project to demonstrate offline-first architecture for field-service style mobile apps.
