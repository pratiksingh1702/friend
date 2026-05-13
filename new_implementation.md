# NEW_FEATURES_IMPLEMENTATION_PLAN.md
## HumanType — Next Phase Features, Architecture & UX Plan
**Version:** 5.0 | **Builds on:** Completed Phases 1–8

---

## FEATURE ROADMAP OVERVIEW

Based on the technical audit, 6 features are approved for implementation.
2 features (Webcam, Windows Login Biometric) are dropped as impractical.

| Priority | Feature | Effort | Platforms Affected |
|----------|---------|--------|-------------------|
| 1 | Shared Scratchpad | 1–2 days | Android + Windows + Bridge |
| 2 | Universal Clipboard Sync | 1–2 days | Android + Windows + Bridge |
| 3 | OTP Auto-Fill | 2–3 days | Android + Bridge |
| 4 | File → Phone Share | 3–4 days | Android + Windows + Bridge |
| 5 | Phone File Browser for Laptop | 4–5 days | Android + Windows + Bridge |
| 6 | Notification Mirror | 3–5 days | Android + Windows |
| — | Phone as Password Vault | 3–4 days | Android + Bridge (downgraded from biometric) |
| ❌ | Phone as Webcam | Dropped | — |
| ❌ | Windows Login Biometric | Dropped | — |

**Estimated total implementation:** ~22–26 days

---

## ARCHITECTURE DECISIONS FOR NEW FEATURES

### Decision 1: Message Routing for New Features

New message types to add to `message_types.dart`:

```dart
// New message types — add to MessageType enum
scratchpad_sync,         // Bidirectional scratchpad content
clipboard_sync,          // Bidirectional clipboard text
otp_detected,           // Android → Bridge: auto-type an OTP
file_transfer_start,    // Sender → Receiver: file metadata
file_transfer_chunk,    // Sender → Receiver: binary chunk
file_transfer_complete, // Sender → Receiver: done signal
file_browse_request,    // Android → Windows: list directory
file_browse_response,   // Windows → Android: directory listing
file_download_request,  // Android → Windows: request a file
notification_mirror,    // Android ↔ Windows: mirror a notification
password_request,       // Windows → Android: request stored password
password_response,      // Android → Windows: authenticated password
```

### Decision 2: Routing Architecture

For v1 of new features, all sync messages route through the Bridge as relay.
For v2 (post-launch), clipboard/scratchpad/files go direct Android ↔ Windows.

```
v1 (now):   Android ←──Bridge relay──→ Windows
v2 (later): Android ←──Direct WS──────→ Windows
            Bridge handles typing only
```

The Bridge relay relay handler:
```python
class SyncRelay:
    async def handle_sync_message(self, msg: dict, sender_id: str):
        # Broadcast to all connected clients except sender
        for client_id, ws in self.connected_clients.items():
            if client_id != sender_id:
                await ws.send(json.dumps(msg))
```

### Decision 3: New Hive Boxes

```dart
HiveBox<ScratchpadEntry>   'scratchpad'      // Scratchpad history (last 50)
HiveBox<ClipboardEntry>    'clipboard_history' // Clipboard history (last 20)
HiveBox<TransferRecord>    'file_transfers'  // Transfer history
HiveBox<PasswordEntry>     'password_vault'  // Encrypted passwords (AES-256)
HiveBox<NotificationEntry> 'notifications'   // Mirrored notification log
```

---

## FEATURE 1: SHARED SCRATCHPAD

### What It Is
A live-syncing text pad visible on both phone and laptop. Type on either device, both update within 200ms. Useful for quick notes, thinking out loud, transferring short text snippets without using clipboard.

### Architecture
```
User types on Android scratchpad →
  debounce 300ms →
  send WsMessage(scratchpad_sync, {content, from: 'android', timestamp}) →
  Bridge broadcasts to Windows →
  Windows renders updated content

Same in reverse for Windows input.
```

### Data Model
```dart
class ScratchpadState {
  final String content;          // Current text
  final DateTime lastModified;
  final String lastModifiedBy;   // 'android' | 'windows'
  final int version;             // Conflict resolution: highest version wins
}
```

### Conflict Resolution
Last-write-wins with debounce. If both devices type simultaneously (rare), the message with the higher `version` number wins. Debounce 300ms prevents flooding.

### Android UI
- New bottom sheet accessible from Home Screen: "Scratchpad"
- Full-screen editor with minimal chrome
- Sync indicator: animated dot (gray = local, green = synced, orange = pending sync)
- History: tap clock icon → last 10 scratchpad sessions
- Actions bar: Copy All, Clear, Share, Send to Text Mode

### Windows UI
- Compact panel inside the Overlay (expanded state): "Scratchpad" section below controls
- OR: Dedicated small floating window (user preference in settings)
- Same sync indicator as Android
- Auto-copy button: one click copies entire scratchpad to Windows clipboard

### UX Improvements Over Naive Implementation
- **No flicker:** Use controlled TextEditingController updates — only update if incoming content differs from current
- **Cursor preservation:** When remote update arrives, preserve local cursor position unless content changed significantly
- **Visual sync pulse:** Brief color flash on the editor border when remote update received
- **Offline mode:** If disconnected, scratchpad still works locally, syncs on reconnect

---

## FEATURE 2: UNIVERSAL CLIPBOARD SYNC

### What It Is
Copy on laptop → paste on phone. Copy on phone → paste on laptop. Instant, automatic, no UI required.

### Architecture
```
Android copies text →
  ClipboardMonitor detects change (platform channel) →
  WsMessage(clipboard_sync, {text, from: 'android', preview: text.substring(0,50)}) →
  Bridge → Windows →
  Windows sets clipboard silently →
  Windows shows brief toast: "Clipboard from phone: [preview]"
```

### Clipboard Monitoring Strategy

**Android** — Platform channel using `ClipboardManager.OnPrimaryClipChangedListener`:
```dart
// Better than polling — event-driven
platform.setMethodCallHandler((call) async {
  if (call.method == 'onClipboardChange') {
    final text = call.arguments['text'] as String?;
    if (text != null && text != _lastSent) {
      _lastSent = text;
      _sendClipboardSync(text);
    }
  }
});
```

**Windows** — Platform channel using `AddClipboardFormatListener`:
```dart
// Register for WM_CLIPBOARDUPDATE messages
// More efficient than polling, gets notified on every clipboard change
```

**Fallback:** 500ms polling on both platforms if platform channel fails.

### UX Design Details

**Android:**
- Silent sync by default (no notification for every clipboard change)
- History panel in Settings → Clipboard Sync: shows last 20 items synced
- Toggle in quick settings tile on notification shade
- Opt-in rich content support (images in v2)

**Windows:**
- Non-intrusive toast in bottom-right (2s auto-dismiss): "📋 Clipboard synced from phone"
- Clipboard history in the Overlay expanded panel: "Recent from phone" section
- Toggle in system tray right-click menu
- Per-session toggle: "Sync clipboard this session" checkbox

### Security Note
Clipboard sync is opt-in, enabled per session. User sees a one-time setup prompt: "Clipboard sync will share your clipboard with your phone over WiFi. Enable?" Not enabled by default.

---

## FEATURE 3: OTP AUTO-FILL

### What It Is
SMS arrives on phone with an OTP code. App detects it, extracts the code, and instantly types it on the laptop — no manual reading or typing needed.

### Architecture
```
SMS arrives on Android →
  SmsReceiver.onReceive() →
  Pattern match: RegExp(r'\b\d{4,8}\b') near "OTP|code|verify|verification" →
  Extract code →
  Show notification: "OTP detected: 482951" + [Type on PC] [Dismiss] buttons →
  User taps "Type on PC" OR auto-types after 3s (configurable) →
  WsMessage(otp_detected, {code: '482951'}) → Bridge →
  Bridge: pyautogui.write(code, interval=0.05) + pyautogui.press('enter')
```

### SMS Permission Handling
- Declare `RECEIVE_SMS` + `READ_SMS` in AndroidManifest
- Request at runtime with explanation: "HumanType needs SMS access to detect OTP codes for auto-fill on your PC"
- For Play Store: declare use case in permission declaration
- For sideload: works immediately after permission granted

### Security Design
- **Never send the full SMS** to Bridge or Windows — only the extracted 4–8 digit code
- OTP codes are not stored in history
- Auto-type has a 3-second confirmation window (user can cancel)
- Show OTP on phone screen for user verification before typing

### Android UI
- OTP detected → persistent notification with:
  - App icon that sent OTP (if detectable)
  - Code preview: "OTP: 482951"
  - Two actions: [Type on PC] [Dismiss]
  - 10-second auto-dismiss if not acted on
- Settings toggle: "Auto-OTP: Auto-type after 3s / Ask every time / Disabled"
- Optional: show OTP history (last 5) with timestamps — off by default

### Bridge Side
```python
async def handle_otp(self, code: str):
    await asyncio.sleep(0.3)   # Brief delay for field focus
    pyautogui.write(code, interval=0.05)
    pyautogui.press('enter')   # Configurable: press Enter or not
    # Send ack back to Android
    await self.send_ack('otp_typed', {'code_length': len(code)})
```

### Windows UI
- Toast: "OTP typed: ●●●●●● (6 digits)" — never show actual code on screen
- In overlay: brief flash indicator "OTP ✓"

---

## FEATURE 4: FILE → PHONE SHARE

### What It Is
Send a file from laptop to phone (or phone to laptop). Drag-and-drop or right-click context menu on Windows. File picker on Android.

### Architecture — Windows to Android
```
Windows: Right-click file → "Send to HumanType Phone" context menu entry
  → Flutter Windows app receives file path
  → Reads file as bytes
  → Splits into 64KB chunks
  → Sends: file_transfer_start → [N × file_transfer_chunk] → file_transfer_complete
  → Android receives, reassembles, saves to Downloads/HumanType/
  → Android shows notification: "Received: document.pdf (2.4 MB)"
```

### Architecture — Android to Windows
```
Android: Share sheet → HumanType | OR in-app file picker button
  → Same chunked transfer in reverse
  → Windows saves to Desktop/HumanType Received/ (configurable)
  → Windows shows toast: "Received: photo.jpg (1.2 MB)"
```

### Data Models
```dart
class FileTransferStart {
  final String transferId;      // UUID for this transfer
  final String fileName;
  final int fileSize;           // bytes
  final int totalChunks;
  final String mimeType;
  final String checksum;        // SHA-256 of full file for verification
}

class FileTransferChunk {
  final String transferId;
  final int chunkIndex;
  final Uint8List data;         // 64KB max
}

class FileTransferComplete {
  final String transferId;
  final String fileName;
  final bool verified;          // checksum matched
}
```

### Windows Context Menu Integration
Registry-based integration via the Windows app's first-launch setup:
```
HKCR\*\shell\HumanTypeSend\
  @="Send to HumanType Phone"
  \command
    @="\"C:\Program Files\HumanType\humantype_windows.exe\" --send-file \"%1\""
```

App launches/activates with `--send-file <path>` argument → starts transfer.

### Progress & UX

**Android receiving:**
- Persistent notification with progress bar during transfer
- Tap notification → opens in appropriate app when done
- Transfer history screen in app

**Windows sending:**
- Progress toast in system tray area
- Can send multiple files (queued)
- Cancel button on in-progress transfer

**Error Handling:**
- Checksum verification on completion → resend failed chunks
- Transfer resumes on reconnect if interrupted (state persisted to Hive)
- Max file size: 500MB (configurable in settings, default 100MB)

---

## FEATURE 5: PHONE FILE BROWSER FOR LAPTOP

### What It Is
Browse and download files from your laptop directly in the Android app. Navigate folders, preview file info, download to phone. Also upload from phone to any folder on laptop.

### Architecture
```
Android sends: WsMessage(file_browse_request, {path: 'C:/Users/Name/Documents'})
  → Bridge → Windows App
  → Windows enumerates directory
  → Sends: WsMessage(file_browse_response, {files: [FileInfo...], path: '...'})
  → Android renders folder tree

Android taps file: sends file_download_request
  → Windows reads file, chunks and sends (same as Feature 4)
  → Android saves to Downloads/HumanType/

Android taps Upload: phone file picker → sends file to Windows
  → Windows saves to current browsed directory
```

### FileInfo Model
```dart
class FileInfo {
  final String name;
  final String path;
  final bool isDirectory;
  final int? sizeBytes;
  final DateTime? lastModified;
  final String? extension;
  final String? mimeType;
}
```

### Android UI — File Browser
```
┌─────────────────────────────────────┐
│  ← Documents              ⊕ Upload  │
├─────────────────────────────────────┤
│  📁 Projects                    →   │
│  📁 School                      →   │
│  📄 Resume.pdf       2.4 MB  3d ago │
│  📄 Report.docx      890 KB  1h ago │
│  🖼 Screenshot.png   1.1 MB  Just   │
│  📊 Budget.xlsx      440 KB  5d ago │
└─────────────────────────────────────┘
```

- Breadcrumb navigation bar at top
- Pull-to-refresh
- Long-press for multi-select → batch download
- File type icons
- Quick preview for images (thumbnail via thumbnail_request message)
- Favorites: pin frequent folders (saved in Hive)
- Search within current folder

### Windows UI (Path Whitelist for Security)
- Settings: "Allowed browse paths" — user defines which folders the phone can access
- Default: Desktop, Documents, Downloads only
- C:\ root browsing disabled unless user explicitly unlocks
- Each browse request validated against whitelist before responding

---

## FEATURE 6: NOTIFICATION MIRROR

### What It Is
Phone notifications appear on laptop; laptop notifications appear on phone. Two-way, with per-app controls.

### Architecture — Phone → Laptop (Works Well)

Android `NotificationListenerService` reads all notifications:
```kotlin
class HumanTypeNotificationService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val app = sbn.packageName
        val title = sbn.notification.extras.getString(Notification.EXTRA_TITLE)
        val body = sbn.notification.extras.getString(Notification.EXTRA_TEXT)
        // Send to Windows via WebSocket
    }
}
```

Windows receives and shows as Windows toast notification:
```dart
// Method channel → Windows Toast API
platform.invokeMethod('showToast', {
  'app_name': notification.appName,
  'title': notification.title,
  'body': notification.body,
  'icon': notification.iconBase64,  // Android app icon
});
```

### Architecture — Laptop → Phone (Partial, User Setup Required)

Windows `UserNotificationListener` (requires user to enable in Windows Settings):
```dart
// Method channel → WinRT UserNotificationListener
// User must allow in: Settings → System → Notifications → 
//   "Allow apps to access your notifications" → ON
```

Forwards to Android as local notification.

**Honest limitations to document:**
- Not all Windows apps use accessible notification APIs
- User must manually enable in Windows Settings once
- Some notifications have content truncated by Windows
- WhatsApp Desktop + some Electron apps may not generate accessible toasts

### Per-App Filter UI

**Android:**
- Settings → Notification Mirror → App list with toggles
- Default: all apps ON (user can selectively disable)
- Group by category: Social, Productivity, System, Other
- Keyword filter: "Mute notifications containing: [OTP, verification, code]" (to avoid duplicate OTP handling)

**Windows:**
- Overlay expanded state: "Recent Notifications" section (last 3, with dismiss)
- Settings → Notification Mirror → per-app toggles (Windows apps)
- Do Not Disturb: "Silence notifications during active typing session"

### UX Refinements
- Notification actions: if Windows notification has reply/dismiss actions, mirror them to phone (future v2)
- Priority filter: only mirror "High" priority Android notifications to Windows
- Quiet hours: configurable time window where no notifications are mirrored

---

## FEATURE 7: PHONE AS PASSWORD VAULT (Downgraded Biometric)

### What It Is
Securely store passwords on your phone (encrypted). When you need to type a password on your laptop, authenticate on phone (fingerprint/face) → phone types it on laptop. NOT Windows unlock. For app passwords only.

### Security Architecture
```
Storage: Hive box 'password_vault', AES-256 encrypted
Key: Derived from Android Keystore, requires biometric auth to unlock

Flow:
  User needs password on laptop →
  Taps "Type password" in Android app (or via a laptop keyboard shortcut) →
  Android shows BiometricPrompt →
  On success: WsMessage(password_response, {password: decrypted}) → Bridge →
  Bridge: pyautogui.write(password) → done
  Password never stored on laptop, never visible on Windows screen
```

### Vault UI (Android)
- Dedicated screen: "Password Vault"
- Add entry: site name, username, password (masked), optional notes
- Biometric prompt on every access (no grace period option)
- Quick-type: tap entry → biometric → types on laptop
- Import from common formats: CSV from browsers
- Export: encrypted `.htvault` file

### Windows Integration
- Keyboard shortcut `Ctrl+Shift+V` → sends `password_request` to Android
- Android vibrates + shows "Password request from PC" → user picks entry + authenticates
- Zero password data stored on Windows side — none

---

## UI/UX OVERHAUL REQUIREMENTS

### Global UI Improvements (Both Platforms)

**1. Spacing & Density Audit**
All screens must pass a density audit: no screen should feel either cramped or wasteful. Apply 4px grid consistently. Section headers must breathe.

**2. Empty States**
Every list/panel that can be empty must have a designed empty state:
- Illustration (SVG, consistent style)
- Descriptive text explaining what goes here
- CTA button to add first item

**3. Loading States**
Every async operation must show a skeleton loader (not a spinner alone):
- File browser loading → skeleton rows
- OCR processing → progress with ETA
- Connection → animated dots

**4. Error States**
Every failure must show:
- Icon (not just text)
- Human-readable explanation (not exception message)
- Primary action: retry or alternate path

**5. Transitions**
All screen transitions must use shared element transitions where applicable (Android) and smooth fade+slide (Windows). No jarring cuts.

**6. Microinteractions**
- Button press: 96% scale (Android), 98% scale (Windows)
- Toggle: spring animation on thumb
- Card expand: height animation with easeOut
- Progress bar: smooth animated fill, not jumping
- Connection quality dot: pulse animation when changing state

### Android-Specific UX Improvements

**Navigation Refinement:**
Replace bottom tab bar with a more gesture-friendly approach:
- Bottom navigation bar stays, but primary action (Text Mode start) gets a prominent FAB
- Add swipe-to-go-back everywhere
- Sheet-based secondary flows (section builder, vault entry, file details)

**Home Screen Redesign:**
Current home is functional but not premium enough. Redesign to:
- Hero card: current connection status with animated connection quality visualization
- Quick-start: most recently used template as a one-tap card
- Feature grid: Text Mode, Code Mode, Scratchpad, Files, Vault — as rich cards with icons + status
- Activity feed: last 3 sessions with quick replay button

**Execution Screen Enhancement:**
- Live character stream: show characters being typed with a subtle trailing glow effect
- Section completion: celebration micro-animation (checkmark + ripple)
- ETA countdown: circular progress ring instead of just number
- Quick speed adjust: tap current WPM badge → speed picker slider slides up

**New Feature Screens:**
All new feature screens follow the same structure:
- Full-bleed dark header with feature icon + name
- Content area with cards
- Floating action button for primary action
- Consistent back/close button (X in top-right for sheets, ← for screens)

### Windows-Specific UX Improvements

**Dashboard Redesign:**
Divide dashboard into clear zones:
- Top bar: connection status + quick actions
- Left panel: session control (always visible)
- Center: live content preview + progress
- Right panel (collapsible): new features panel (scratchpad, clipboard, notifications)

**Overlay Enhancement:**
- New collapsed state: shows current WPM in real-time (not just status dot)
- Expanded state: add Scratchpad tab + Clipboard tab + Files tab
- Smooth tab switching inside overlay with slide animation
- Overlay resize handle: drag corner to resize (min 180px, max 320px wide)

**Notification area in Overlay:**
```
┌───────────────────────────────┐
│  🔔 Notifications      View all│
├───────────────────────────────┤
│  WhatsApp · 2m ago            │
│  "Hey, are you free tonight?" │
├───────────────────────────────┤
│  Gmail · 5m ago               │
│  "Your order has shipped"     │
└───────────────────────────────┘
```

**Settings UX:**
Group settings by workflow, not technical category:
- "When Typing" (speed, errors, behavior)
- "Connectivity" (WiFi, Bluetooth, auto-connect)
- "Privacy & Security" (vault, clipboard, notifications permissions)
- "Sync Features" (scratchpad, clipboard, files, notifications)
- "Advanced" (ports, stealth, compatibility)

---

## PERFORMANCE OPTIMIZATION PLAN

### Android
- Lazy load feature modules (Templates, History, Vault not loaded until first access)
- Compress clipboard sync: text > 5KB → gzip before sending
- File transfer: use Isolate for chunk reading (avoid UI thread blocking)
- Notification listener: background isolate, never on main thread

### Windows
- Overlay render: ensure 60fps by keeping widget tree shallow
- File browser: paginate directory listings (50 items per page)
- Clipboard monitoring: use `AddClipboardFormatListener` not polling
- Notifications: debounce 200ms to avoid rapid-fire notification floods

### Bridge
- File transfers: use asyncio Streams, not raw bytes — backpressure aware
- Bump rate limit to 5000 cmd/min for sessions where file transfer is active
- Add a message queue per client — never block the main event loop

---

## SECURITY PLAN FOR NEW FEATURES

| Feature | Risk | Mitigation |
|---------|------|-----------|
| Clipboard Sync | Sensitive data (passwords, keys) auto-synced | Opt-in per session + keyword filter to exclude sensitive content |
| File Browser | Laptop file system exposed to phone | Path whitelist in settings + user must explicitly enable |
| Password Vault | Compromise of vault = all passwords lost | AES-256 Hive + Biometric required per access + no cloud sync |
| OTP Auto-Fill | SMS interception concern | OTP never stored + never relayed in full + shown to user before typing |
| Notification Mirror | Private notifications mirrored to laptop | Per-app filter + keyword exclusion + user-controlled |

---

## ACCESSIBILITY PLAN

- All new interactive elements: minimum 48dp touch target (Android), 32px (Windows)
- All status indicators: never color-only — always color + icon + text
- Notification mirror: respect Android accessibility settings (DND, etc.)
- File browser: content descriptions on all file type icons
- Password vault: biometric prompt has accessible fallback (PIN)
- Scratchpad: full keyboard navigation on Windows

---

## TESTING STRATEGY

### Priority Unit Tests (Shared Package)
1. `execution_planner_test.dart` — verify queue correctness for 20+ input variations
2. `error_injector_test.dart` — verify placement rules (no first char, no consecutive)
3. `humanizer_test.dart` — verify variance is within ±15%, never exactly the same delay twice
4. `ws_message_test.dart` — serialization + deserialization round-trip for all message types

### Integration Tests
1. End-to-end: Android sends text → Bridge types it → progress reported back
2. Clipboard sync: copy on Android → verify Windows clipboard updated
3. File transfer: 10MB file → checksum verified on both ends
4. OTP: mock SMS → verify code typed on laptop within 5s

### Manual Test Matrix for New Features
| Test | Device A | Device B | Expected |
|------|---------|---------|---------|
| Scratchpad sync | Type on Android | Check Windows | Updates within 200ms |
| Clipboard sync | Copy on Windows | Check Android | Clipboard updated |
| File transfer | Send 50MB file | Receive on phone | Checksum matches |
| OTP | Receive SMS | Check laptop | Code typed in field |

---

## DEPLOYMENT CONSIDERATIONS

### Android
- New permissions require manifest update + runtime request
- Play Store: OTP permission needs detailed declaration
- Sideload: all features work without store restrictions

### Windows
- Context menu integration requires admin rights at first install
- `UserNotificationListener` requires user to enable in Windows Settings (one-time prompt in UI)
- New settings need migration: `AppSettings` model version bump + Hive migration

### Bridge
- New message types are backward-compatible (old Bridge ignores unknown types gracefully)
- File transfer requires increasing WebSocket message size limit in `websockets` config
- Bundle size will increase slightly with new relay logic

---

*Implementation plan complete. See AGENT_ANDROID_BRIEF.md and AGENT_WINDOWS_BRIEF.md for platform-specific build instructions.*