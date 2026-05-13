# HumanType — AGENT 2: Windows Update Spec
### *New Features Addition — v5.0*

**Version:** 5.0 | **Status:** Phases 1–8 Complete → Now adding Phase 9 features  
**Assumption:** All existing features (Phases 1–8) are DONE and working. Do not re-implement or re-explain them.

---

## 1. Feature Mapping (Android ↔ Windows)

| Feature | Android Side (Agent 1) | Windows Side (Agent 2) | Status |
|---------|------------------------|------------------------|--------|
| **1. OTP Auto-Fill** | Detects SMS OTP -> Sends `otp_detected` | **Bridge** types the code via `pyautogui` | Ready to Implement |
| **2. Shared Scratchpad** | Full-screen editor, bidirectional sync | **Windows App** overlay panel, bidirectional sync | Ready to Implement |
| **3. Clipboard Sync** | Polls clipboard, sends `clipboard_sync` | **Windows App** Win32 listener, bidirectional sync | Ready to Implement |
| **4. Notification Mirror** | Forwards phone notifications to PC | **Windows App** shows toasts; forwards PC notifications | Ready to Implement |
| **5. File Share** | Picks file -> Sends chunks | **Windows App** Explorer context menu -> Sends chunks | Ready to Implement |
| **6. File Browser** | UI to browse & request files | **Windows App** enumerates folders & serves chunks | Ready to Implement |

---

## 2. Implementation Specifications

### 2.1 OTP Auto-Fill (Bridge Side)
**Goal:** Receive `otp_detected` and type it instantly.
- **File:** `bridge/humantype_bridge/server/websocket_server.py`
- **Logic:** Add `otp_detected` to `_handle_message`.
- **Payload:** `{ "code": "123456" }`
- **Execution:** `pyautogui.write(code, interval=0.05)`

### 2.2 Shared Scratchpad (Windows Side)
**Goal:** Real-time text pad in the HUD.
- **File:** `apps/humantype_windows/lib/features/scratchpad/widgets/scratchpad_panel.dart`
- **UI:** Transparent glassmorphic panel in Overlay. Use `JetBrains Mono`.
- **Sync:** Send `scratchpad_sync` on change (debounced 300ms).
- **Conflict:** Last-write-wins by timestamp.

### 2.3 Universal Clipboard Sync
**Goal:** Automatic clipboard sharing.
- **File:** `apps/humantype_windows/lib/features/clipboard/services/windows_clipboard_manager.dart`
- **Logic:** Register `AddClipboardFormatListener` via `win32` FFI.
- **Relay:** Send `clipboard_sync` when local clipboard changes. Update local clipboard when remote sync arrives.
- **Prevention:** Avoid infinite loops using a "remote_update" flag.

### 2.4 Notification Mirroring
**Goal:** Show phone notifications on PC; send PC notifications to phone.
- **Phone → PC:** Use `win32` Toast APIs to show incoming `notification_mirror` payloads.
- **PC → Phone:** Use `UserNotificationListener` (WinRT) to detect local toasts and send to phone.
- **Toggle:** Settings to enable/disable "Mirror PC notifications".

### 2.5 File Transfer (Send to Phone)
**Goal:** Right-click context menu in Windows Explorer.
- **Registry:** `HKCR\*\shell\HumanTypeSend` -> `humantype_windows.exe --send-file "%1"`.
- **Handling:** Split file into 64KB chunks. Send `file_transfer_start` -> chunks -> `file_transfer_complete`.
- **UI:** Show progress bar in the system tray or overlay.

### 2.6 Remote File Browser (Server)
**Goal:** Allow phone to browse PC files.
- **Security:** Whitelist `Documents`, `Desktop`, `Downloads`.
- **Browse:** Handle `file_browse_request`, return directory listing in `file_browse_response`.
- **Download:** Handle `file_download_request` by starting a chunked transfer to phone.

---

## 3. Technical Requirements

### New Message Types (Already in Shared)
- `otp_detected`
- `scratchpad_sync`
- `clipboard_sync`
- `notification_mirror`
- `file_transfer_start/chunk/complete`
- `file_browse_request/response`

### Windows Dependencies
- `win32`: ^5.5.0
- `tray_manager`: ^0.2.2
- `windows_notification`: ^0.0.1
- `hotkey_manager`: ^0.1.8

---

*AGENT 2 — Windows Update Spec v5.0*
