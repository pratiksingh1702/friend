# HumanType Android — Agent 1 Task Plan

## Phase 1 — Foundation (Weeks 1–3)
- [x] Setup project structure + shared package
- [x] Define ALL models and message types in shared package
- [x] Basic WebSocket connection to bridge
- [x] Handshake + capability exchange
- [x] Simple text → send as commands (no humanization yet)
- **Milestone:** "Hello World" typed on laptop from phone

## Phase 2 — Human Engine (Weeks 4–7)
- [x] Humanizer (rhythm + variance)
- [x] Error injector (all types + corrections)
- [x] Execution planner (full queue builder)
- [x] Speed profiles
- [x] Pause / Resume / Stop
- **Milestone:** 500-word essay typed, feels fully human

## Phase 3 — Section System (Weeks 8–10)
- [x] Section model + builder UI
- [x] Pre/post actions
- [x] Manual section start (tap to proceed)
- [x] Progress tracking
- **Milestone:** 4-field form filled from phone

## Phase 4 — Code Mode (Weeks 11–12)
- [x] Language detector
- [x] Code zone mapper
- [x] Code rhythm engine
- [x] Code mode UI
- **Milestone:** 50-line Python function typed realistically

## Phase 5 — Connection (Weeks 13–14)
- [x] mDNS auto-discovery
- [ ] Bluetooth fallback
- [ ] Auto-connect on launch
- [ ] Reconnect during session
- **Milestone:** Opens app → connected in <2s

## Phase 6 — Windows Sync (Weeks 15–16)
- [ ] Receive OCR results from Windows app
- [x] Settings sync with Windows app
- [ ] Stealth mode signal handling
- **Milestone:** Capture screen on Windows, AI processes on Android

## Phase 7 — AI Layer (Weeks 17–18)
- [ ] Claude API integration
- [x] Natural language instruction parser
- [ ] OCR result processing
- **Milestone:** Type instructions in plain English → sections created

## Phase 8 — Polish (Weeks 19–20)
- [ ] Full design system on all screens
- [ ] Onboarding flow
- [ ] Empty/error/loading states everywhere
- [x] Templates + history
- [x] WakeLock during execution
- [x] Haptic feedback
- **Milestone:** Beta-ready APK
---

# HumanType Windows & Bridge — Agent 2 Task Plan

## Phase 1 — Python Bridge (Executor)
- [x] Environment Setup (`requirements.txt`)
- [x] Implement `security/token_validator.py`
- [x] Implement `discovery/mdns_broadcast.py`
- [x] Implement `executor/keyboard_executor.py` & `command_parser.py`
- [x] Implement `server/websocket_server.py`
- [x] Implement `tray/tray_icon.py`
- [x] Implement `main.py` & async orchestration
- **Milestone:** Bridge running, broadcasting, and typing from manual WS input

## Phase 2 — Windows App Foundation
- [x] Configure `pubspec.yaml` with Windows-specific dependencies
- [x] Setup GoRouter + Riverpod architecture
- [x] Implement Fluent Design System (theme.dart)
- [x] App Dashboard (Sync status, paired devices)
- **Milestone:** Windows app launches with premium design

## Phase 3 — Overlay System (Stealth)
- [x] Implement `WDA_EXCLUDEFROMCAPTURE` via Win32 API
- [x] Floating HUD window with transparency (overlay_ui.dart)
- [x] HUD state sync (visible/collapsed/stealth)
- [x] Mouse-aware auto-collapse logic
- **Milestone:** Overlay visible to user but invisible to recordings

## Phase 4 — Screen OCR & Capture
- [x] Screen capture service (`screen_retriever`)
- [x] OCR engine integration (Windows Native / Tesseract fallback)
- [x] Selection tool (Area capture UI)
- [x] Real-time text extraction loop
- **Milestone:** Select screen area → Text sent to Android app

## Phase 5 — Settings & Sync
- [x] Bidirectional settings sync (Android <-> Windows)
- [x] Localhost sync (Windows App <-> Bridge)
- [x] System tray integration for Windows App
- [x] Auto-connect + startup registration
- **Milestone:** Change setting on phone → Windows app updates instantly

## Phase 6 — Calibration & Field Mapping
- [x] Field calibration UI (Mirror mode)
- [x] Coordinate mapping logic
- [x] Field map storage (Hive)
- **Milestone:** Tap field on phone → Windows app highlights target location

## Phase 7 — Final Integration & Polish
- [x] Packaging (PyInstaller for bridge, MSIX for Flutter)
- [x] Error handling & reconnection logic
- [x] Stealth/Demo mode deep-dive implementation
- **Milestone:** Product-ready Windows deployment
