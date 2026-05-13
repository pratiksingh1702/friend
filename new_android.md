# HumanType — AGENT 1: Android Update Spec
### *New Features Addition — v5.0*

**Version:** 5.0 | **Status:** Phases 1–8 Complete → Now adding Phase 9 features  
**Assumption:** All existing features (Phases 1–8) are DONE and working. Do not re-implement or re-explain them.

---

> ⚠️ **AGENT COORDINATION — v5.0**
>
> Agent 2 is simultaneously updating the Windows App + Python Bridge.
>
> **New message types added in this update (you send/receive):**
> - `scratchpad_sync` — bidirectional text relay via Bridge
> - `clipboard_sync` — bidirectional clipboard relay via Bridge
> - `notification_mirror` — phone → Windows toast forwarding
> - `file_transfer_start`, `file_transfer_chunk`, `file_transfer_complete` — chunked file sending
> - `file_browse_request` / `file_browse_response` — remote file browser
> - `otp_detected` — you detect OTP from SMS, send to Bridge for typing
>
> All new message types follow the existing `WsMessage` envelope in `humantype_shared`.  
> Add new `MessageType` enum values to `message_types.dart` in the shared package.  
> Coordinate with Agent 2 before finalizing payload schemas.

---

## Phase 9 — New Features

---

### 9.1 OTP Auto-Fill

**What it does:** Detects incoming OTP/verification codes from SMS on the Android device. Sends the extracted code to the Bridge, which types it into the active field on the laptop.

**Permissions required:**
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.READ_SMS" />
```

**New file:** `features/otp/services/sms_listener_service.dart`

```dart
// Registers a broadcast receiver for incoming SMS.
// Extracts 4–8 digit codes near keywords: OTP, code, verification, one-time, use.
// Regex: RegExp(r'\b\d{4,8}\b')
// On match → send WsMessage of type otp_detected to Bridge.

class SmsListenerService {
  Stream<String> get otpStream; // emits extracted code strings
  void startListening();
  void stopListening();
}
```

**New message type payload:**
```json
{
  "type": "otp_detected",
  "payload": {
    "code": "482951",
    "source_app": "SMS",
    "raw_snippet": "Your code is 482951. Do not share."
  }
}
```

**Android UI — OTP indicator:**
- Show a non-intrusive banner in `home_screen.dart` when an OTP is detected: `"OTP 482951 — Tap to type on laptop"`
- Tapping the banner sends the `otp_detected` message
- Auto-dismiss after 60 seconds
- If no laptop is connected, banner shows `"OTP copied to clipboard"` instead and copies it

**Provider:** `features/otp/providers/otp_provider.dart`
- State: `{String? pendingOtp, DateTime? detectedAt, bool autoSent}`
- Auto-send setting: if enabled in settings, skip the banner and send immediately

**Settings toggle:** Under Settings → Connectivity → `"OTP Auto-Fill"` (default: ON, prompt on first detection)

**Play Store note:** SMS permission will require justification in Play Store declaration. The APK sideload path has no restriction. Build the feature; document the Play Store limitation inline in code comments.

---

### 9.2 Shared Scratchpad

**What it does:** A persistent, real-time-synced notepad visible on both Android and Windows. Both sides can edit; changes propagate within ~500ms via Bridge relay.

**Architecture:**
```
Android edits text
  → debounce 300ms
  → send scratchpad_sync to Bridge
  → Bridge broadcasts to all other connected clients
  → Windows Flutter receives + updates its scratchpad UI
```

**New file:** `features/scratchpad/screens/scratchpad_screen.dart`

UI requirements:
- Full-screen editor — dark background, `JetBrains Mono` font, 14sp
- Top bar: `"Scratchpad"` title + sync status indicator (green pulse = synced, grey = local changes pending)
- Character count bottom right (subtle, `caption` style)
- Floating action button: `"Send to laptop"` (manual send, in addition to auto-sync)
- Long-press FAB: `"Clear"` with confirmation dialog
- Empty state: `"Start typing. It appears on your laptop instantly."`

**Provider:** `features/scratchpad/providers/scratchpad_provider.dart`
```dart
// State:
class ScratchpadState {
  final String content;
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final String? lastSyncedBy; // 'android' or 'windows'
}
```

**Message payload:**
```json
{
  "type": "scratchpad_sync",
  "payload": {
    "content": "full text content here",
    "last_modified_by": "android",
    "timestamp_ms": 1700000000000
  }
}
```

Conflict resolution: last-write-wins by `timestamp_ms`. No merge — simpler and correct for single-user use.

**Navigation:** Add `"Scratchpad"` to bottom nav bar or home screen quick-actions grid (whichever is currently used). Use a `notes_outlined` icon.

---

### 9.3 Cross-Device Clipboard Sync

**What it does:** When the user copies text on either device, it automatically appears on the other device's clipboard within ~500ms.

**New file:** `features/clipboard/services/clipboard_monitor_service.dart`

```dart
// Poll Clipboard.getData every 500ms.
// On change (text != _lastClipboard):
//   - Update _lastClipboard
//   - If change originated locally (not from a sync message), send clipboard_sync to Bridge
// Guard: ignore clipboard updates that arrived FROM the network (to prevent echo loops)
//   - Use a bool flag _suppressNextChange that is set before applying incoming sync

class ClipboardMonitorService {
  void start();
  void stop();
  Stream<String> get outgoingClipboardStream; // text the user copied locally
  void applyIncoming(String text); // sets clipboard + suppresses echo
}
```

**Message payload:**
```json
{
  "type": "clipboard_sync",
  "payload": {
    "content": "copied text here",
    "content_type": "text",
    "source": "android",
    "char_count": 42
  }
}
```

**Android UI:**
- When a clipboard sync arrives FROM Windows, show a brief snackbar: `"📋 Clipboard from PC — tap to view"` with a `View` action that opens a bottom sheet showing the full content
- The snackbar auto-dismisses after 4 seconds
- No snackbar for outgoing (user copied it themselves — they know)

**Settings:** Under Settings → Connectivity → `"Clipboard Sync"` (default: ON)  
Add a sub-option: `"Show notification when clipboard arrives"` (default: ON)

**Provider:** `features/clipboard/providers/clipboard_provider.dart`
```dart
class ClipboardState {
  final String? lastReceivedContent;
  final String? lastReceivedFrom; // 'windows'
  final DateTime? lastReceivedAt;
}
```

**Lifecycle:** Start monitor when connected, stop when disconnected. Restart on reconnect.

---

### 9.4 Notification Mirror (Phone → Laptop)

**What it does:** Android notifications appear as Windows toast notifications on the laptop. User can dismiss from either device.

**Permission required:**
```xml
<uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />
```

Requires user to enable in Android Settings → Accessibility → Notification Access. Prompt user on first use with instructions.

**New file:** `features/notifications/services/notification_listener_service.dart`

```dart
// Extends NotificationListenerService (platform channel to native Android)
// Filters: exclude system notifications, HumanType's own notifications
// Include: messaging apps, email, calendar, custom app whitelist

class NotificationMirrorService {
  Stream<MirroredNotification> get notificationStream;
  void startListening();
  void stopListening();
  Future<bool> get hasPermission;
  Future<void> openPermissionSettings();
}

class MirroredNotification {
  final String appName;
  final String? appPackage;
  final String title;
  final String body;
  final DateTime timestamp;
  final String id; // for dismissal tracking
}
```

**Message payload:**
```json
{
  "type": "notification_mirror",
  "payload": {
    "id": "uuid",
    "app_name": "WhatsApp",
    "app_package": "com.whatsapp",
    "title": "Priya",
    "body": "Can you review the Q3 report?",
    "timestamp_ms": 1700000000000
  }
}
```

**Settings screen:** Under Settings → Notifications → `"Mirror to Laptop"`
- Master toggle
- Per-app whitelist (default: messaging apps only — WhatsApp, Telegram, Messages, Gmail)
- `"Only when screen is off"` option (default: OFF)

**Onboarding prompt:** On first toggle-ON, show a dialog explaining the permission requirement + a `"Open Settings"` button that deep-links directly to the Notification Access settings page.

---

### 9.5 File Transfer — Send to Laptop

**What it does:** User picks a file on Android (via file picker), it gets chunked and sent to the laptop's Downloads folder via the Bridge relay.

**New files:**
- `features/file_transfer/services/file_sender_service.dart`
- `features/file_transfer/screens/file_transfer_screen.dart`
- `features/file_transfer/providers/file_transfer_provider.dart`

**Sender logic:**
```dart
// Chunk size: 65536 bytes (64KB)
// Protocol:
//   1. Send file_transfer_start (metadata)
//   2. Send N file_transfer_chunk messages (binary payload as base64)
//   3. Send file_transfer_complete

class FileSenderService {
  // Returns a Stream<TransferProgress> so UI can show progress bar
  Stream<TransferProgress> sendFile(String filePath);
  Future<void> cancelTransfer(String transferId);
}

class TransferProgress {
  final String transferId;
  final int bytesSent;
  final int totalBytes;
  final double progressFraction; // 0.0 to 1.0
  final TransferStatus status; // idle | sending | complete | error | cancelled
}
```

**Message payloads:**
```json
// file_transfer_start
{
  "type": "file_transfer_start",
  "payload": {
    "transfer_id": "uuid",
    "file_name": "report.pdf",
    "file_size_bytes": 2048000,
    "total_chunks": 32,
    "mime_type": "application/pdf"
  }
}

// file_transfer_chunk
{
  "type": "file_transfer_chunk",
  "payload": {
    "transfer_id": "uuid",
    "chunk_index": 0,
    "data_base64": "...",
    "is_last": false
  }
}

// file_transfer_complete
{
  "type": "file_transfer_complete",
  "payload": {
    "transfer_id": "uuid",
    "file_name": "report.pdf",
    "checksum_md5": "abc123"
  }
}
```

**Android UI — `file_transfer_screen.dart`:**
- Button: `"Pick File"` → opens Flutter file picker (any file type)
- After pick: shows file name, size, type icon
- Send button: `"Send to Laptop"`
- During transfer: linear progress bar + `"X.X MB / Y.Y MB"` + percentage + estimated time
- Cancel button during transfer
- On complete: `"✓ Saved to Downloads on laptop"` success state
- On error: friendly message + retry button

**Entry point:** Home screen quick-actions grid — `"Send File"` tile with upload icon. Also accessible from a long-press context menu on files in the file browser (Feature 9.6).

**File size limit (v1):** 100MB. Show error if file exceeds this. Document that large files are slow through Bridge relay; direct connection in v2.

---

### 9.6 Phone File Browser (Browse & Download from Laptop)

**What it does:** Browse the Windows file system from the Android app. Tap a file to download it to the phone.

**New files:**
- `features/file_browser/screens/file_browser_screen.dart`
- `features/file_browser/providers/file_browser_provider.dart`
- `features/file_browser/models/remote_file_info.dart`

**Model:**
```dart
class RemoteFileInfo {
  final String name;
  final String path; // full Windows path
  final bool isDirectory;
  final int? sizeBytes;
  final DateTime? modifiedAt;
  final String? mimeType;
}
```

**Protocol — request/response (new message types):**
```json
// You send:
{
  "type": "file_browse_request",
  "payload": {
    "request_id": "uuid",
    "path": "C:/Users/Name/Documents"
  }
}

// You receive:
{
  "type": "file_browse_response",
  "payload": {
    "request_id": "uuid",
    "path": "C:/Users/Name/Documents",
    "files": [
      {
        "name": "report.pdf",
        "path": "C:/Users/Name/Documents/report.pdf",
        "is_directory": false,
        "size_bytes": 204800,
        "modified_at_ms": 1700000000000
      }
    ],
    "error": null
  }
}
```

**Android UI — `file_browser_screen.dart`:**
- Top bar: current path with breadcrumb trail (scrollable horizontally) + back arrow
- Initial path: `C:/Users/{username}/` (Windows app sends username in `file_browse_response` metadata on first request)
- File list: `ListView` with icon (folder vs file type icon), name, size, modified date
- Tap folder → navigate in, send new `file_browse_request`
- Tap file → show bottom sheet: name, size, modified date + `"Download to Phone"` button
- Download triggers `FileSenderService` in reverse (Windows sends, Android receives)
- Long-press file: `"Send to this folder"` option (uploads from phone to that folder)
- Pull-to-refresh to re-fetch current directory
- Empty folder: `"This folder is empty"` state
- Error (path not accessible): `"Can't access this folder"` with retry

**Provider state:**
```dart
class FileBrowserState {
  final String currentPath;
  final List<RemoteFileInfo> files;
  final bool isLoading;
  final String? error;
  final List<String> breadcrumbs; // navigation history
}
```

**Entry point:** Home screen quick-actions grid — `"Browse Laptop"` tile with folder-open icon.

---

### 9.7 Claude API — Update to Current Model

**This is a technical debt fix from the architecture audit.**

**File to update:** `packages/humantype_shared/lib/ai_engine/claude_api_service.dart`

Change the model string from whatever legacy value is currently used to:
```dart
static const String _model = 'claude-sonnet-4-20250514';
```

Also update the API call structure if it uses the legacy completion endpoint. The current Messages API format:
```dart
final response = await http.post(
  Uri.parse('https://api.anthropic.com/v1/messages'),
  headers: {
    'Content-Type': 'application/json',
    'x-api-key': apiKey,
    'anthropic-version': '2023-06-01',
  },
  body: jsonEncode({
    'model': 'claude-sonnet-4-20250514',
    'max_tokens': 1024,
    'messages': [
      {'role': 'user', 'content': prompt}
    ],
  }),
);
```

No other changes to the `AiService` interface — the abstraction already handles this.

---

## New Shared Package Additions

Add these `MessageType` enum values to `message_types.dart`:

```dart
// Phase 9 additions
otpDetected,
scratchpadSync,
clipboardSync,
notificationMirror,
fileTransferStart,
fileTransferChunk,
fileTransferComplete,
fileBrowseRequest,
fileBrowseResponse,
```

Add these model files to `packages/humantype_shared/lib/models/`:
- `transfer_progress_model.dart` — `TransferProgress`, `TransferStatus`
- `remote_file_info.dart` — `RemoteFileInfo`
- `mirrored_notification.dart` — `MirroredNotification`

---

## Updated pubspec.yaml — Android App Additions

Add to the existing `dependencies` in `humantype_android/pubspec.yaml`:

```yaml
  # Phase 9 additions
  file_picker: ^8.0.0              # File picking for transfer
  telephony: ^0.2.0                # SMS reading for OTP
  flutter_local_notifications: ^17.0.0  # OTP banner + clipboard notifications
  path_provider: ^2.1.0            # Save incoming files to Downloads
  crypto: ^3.0.3                   # MD5 checksum for file transfer (already present — confirm)
  mime: ^1.0.4                     # MIME type detection for file transfers
```

---

## Updated Navigation / Home Screen

Add the following quick-action tiles to the home screen grid (or wherever the current quick-actions surface is):

| Tile | Icon | Action |
|------|------|--------|
| Send File | `upload_file` | Opens `FileTransferScreen` |
| Browse Laptop | `folder_open` | Opens `FileBrowserScreen` |
| Scratchpad | `edit_note` | Opens `ScratchpadScreen` |

The OTP banner appears inline on the home screen (not a tile — it's a conditional banner between the connection status chip and the quick-actions grid).

---

## Settings Screen Additions

Under Settings, add a new section: **"Connectivity Features"** (between existing Connection and AI sections):

| Setting | Default | Description |
|---------|---------|-------------|
| OTP Auto-Fill | ON | Auto-detect and type OTP codes |
| OTP Auto-Send | OFF | Send without confirmation tap |
| Clipboard Sync | ON | Sync clipboard between devices |
| Show clipboard notification | ON | Banner when clipboard arrives from PC |
| Notification Mirror | OFF | Forward phone notifications to laptop |
| Notification apps | [WhatsApp, Gmail, Messages] | App whitelist for mirroring |

---

## Performance Targets — New Features

| Feature | Metric | Target |
|---------|--------|--------|
| OTP detection → Bridge send | End-to-end | < 3s from SMS arrival |
| Scratchpad sync | Propagation latency | < 500ms |
| Clipboard sync | Propagation latency | < 500ms |
| Notification mirror | Propagation latency | < 1s |
| File transfer (10MB) | Transfer time on local WiFi | < 15s |
| File browser directory load | Response time | < 1s |

---

## Error Handling — New Features

| Scenario | Behavior |
|----------|----------|
| SMS permission denied | Show settings deep-link prompt, disable OTP feature gracefully |
| Notification permission denied | Same pattern — settings link + graceful disable |
| File transfer interrupted | Auto-retry once, then show error with retry button, clean up partial transfer |
| File browse — path not found | Show `"Folder not accessible"` + retry, fallback to root |
| Clipboard sync loop | `_suppressNextChange` flag prevents echo; if loop detected (3 identical rapid syncs), pause sync for 2s |
| Scratchpad conflict (both edit simultaneously) | Last-write-wins by timestamp. No merge. Losing edit silently discarded (v1 behavior — document this) |

---

*AGENT 1 — Android Update Spec v5.0*  
*HumanType | Phases 1–8 complete. This file covers Phase 9 new features only.*  
*Agent 2 is updating Windows App + Python Bridge in parallel.*