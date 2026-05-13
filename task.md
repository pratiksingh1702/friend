# HumanType — Full Project Task Plan

## Phase 1 — Foundation (DONE)
- [x] **Shared:** Setup project structure + shared package
- [x] **Shared:** Define ALL models and message types in shared package
- [x] **Bridge:** Core Python infrastructure (Handshake, Token Validation, WebSocket Server)
- [x] **Bridge:** mDNS broadcasting (`_humantype._tcp.local`)
- [x] **Android:** WiFi WebSocket client + Handshake
- [x] **Android:** Basic text → send as commands
- [x] **Windows:** Basic Flutter Windows shell + Shared package import
- **Milestone:** "Hello World" typed on laptop from phone via Bridge

## Phase 2 — Human Engine (DONE)
- [x] **Shared:** Humanizer logic (rhythm + variance)
- [x] **Shared:** Error injector (all types + corrections)
- [x] **Shared:** Execution planner (full queue builder)
- [x] **Android:** Speed profiles UI + Speed selection
- [x] **Android:** Pause / Resume / Stop controls
- [x] **Bridge:** Keyboard executor (pyautogui integration)
- **Milestone:** 500-word essay typed, feels fully human

## Phase 3 — Section System (DONE)
- [x] **Shared:** Section model + JSON serialization
- [x] **Android:** Section builder UI (Add/Edit/Remove)
- [x] **Android:** Manual section start (tap to proceed)
- [x] **Android:** Progress tracking UI
- [x] **Bridge:** Pre/Post action execution (Enter/Tab)
- **Milestone:** Multi-field form filled from phone with manual breaks

## Phase 4 — Code Mode (DONE)
- [x] **Shared:** Code analyzer (Language detector, Code zone mapper)
- [x] **Shared:** Code rhythm engine
- [x] **Android:** Code mode UI (Dark editor aesthetic)
- [x] **Bridge:** Special key support (Shift, Ctrl, Alt, F-keys)
- **Milestone:** 50-line Python function typed with realistic coding rhythm

## Phase 5 — Connection & Robustness
- [x] **Android:** mDNS auto-discovery UI
- [x] **Android:** Auto-connect on launch (Last known bridge)
- [x] **Android:** Bluetooth fallback (Logic implemented)
- [x] **Bridge:** Reconnect handling (Graceful disconnect)
- [x] **Bridge:** Bluetooth server implementation
- **Milestone:** Open app → auto-connected in <2s

## Phase 6 — Windows Sync
- [x] **Windows:** Floating Overlay HUD (WDA_EXCLUDEFROMCAPTURE)
- [x] **Windows:** OCR Service (Screen capture + Text extraction)
- [x] **Android:** OCR Result processing (Receiver + AI hook)
- [x] **Shared:** Settings sync protocol (Bidirectional)
- [x] **Android:** Stealth mode signal handling
- [x] **Windows:** Stealth mode UI visibility toggle
- **Milestone:** Capture screen on Windows, results appear on Android

## Phase 7 — AI Layer (Agnostic)
- [x] **Shared:** Agnostic `AiService` interface
- [x] **Shared:** Gemini API integration
- [x] **Shared:** Claude API integration (Legacy)
- [x] **Android:** Natural language instruction parser
- [x] **Android:** "Ask AI" button for OCR results
- **Milestone:** Type instructions in plain English → sections created automatically

## Phase 8 — Polish & Production
- [x] **Android:** Full design system audit
- [x] **Android:** Onboarding flow (First run)
- [x] **Android:** History + Templates management
- [x] **Windows:** System tray integration (TrayManager)
- [x] **Windows:** Field calibration system (Screen mapping)
- [x] **Bridge:** Single EXE packaging (PyInstaller)
- [x] **Global:** Final testing of end-to-end sync
- **Milestone:** Production-ready APK + Windows Installer

## Phase 9 — HumanType v5.0 (New Features)
- [x] **Shared:** Update `MessageType` enum and add data models (`RemoteFileInfo`, `MirroredNotification`)
- [x] **Bridge:** Implement relay logic for `scratchpad_sync` and `clipboard_sync`
- [x] **Bridge:** Implement `otp_detected` and `password_response` typing execution
- [x] **Windows:** Shared Scratchpad UI + Sync logic
- [x] **Windows:** Universal Clipboard Sync (Win32 Listener + Relay)
- [x] **Windows:** Notification Mirroring (Phone → Windows Toast)
- [/] **Windows:** Notification Mirroring (Windows → Phone via UserNotificationListener) - *Partial: Listener requires WinRT integration*
- [x] **Windows:** File Transfer (Send to Phone context menu + Chunking)
- [x] **Windows:** Phone File Browser (Serve directory listing + File chunks)
- [x] **Windows:** Password Vault integration (Global hotkey `Ctrl+Shift+V` → Request)
- [ ] **Android:** (Phase 9 tasks as per Agent 1 brief)
- **Milestone:** Full feature parity and seamless cross-device synchronization.