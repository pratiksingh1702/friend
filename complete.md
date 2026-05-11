# HumanType — Complete Product System Design
### *The Intelligent Human-Like Remote Typing System*

**Version:** 4.0 — Bidirectional & Scalable Architecture  
**Platforms:** Android (Flutter) + Windows (Flutter Desktop)  
**Classification:** Full Product Architecture | Future-Proof | Bidirectional  

---

> **Product Tagline:**  
> *"Your words. Your control. Any device. Any direction."*

---

## Table of Contents

```
PART A — PRODUCT OVERVIEW
  A1. Vision & Mission
  A2. Core Philosophy
  A3. System Topology
  A4. Technology Decisions

PART B — ANDROID APP (Flutter)
  B1. App Architecture
  B2. Feature Specifications
  B3. AI & Human Simulation Engine
  B4. Section & Instruction System
  B5. Code Mode Intelligence
  B6. Connection Management
  B7. UI/UX Design System (Android)
  B8. State Management
  B9. Local Storage

PART C — WINDOWS APP (Flutter Desktop)
  C1. App Architecture
  C2. Feature Specifications
  C3. Screen Overlay System
  C4. WDA_EXCLUDEFROMCAPTURE — Deep Dive
  C5. Stealth / Demo Mode
  C6. Screen OCR & Capture
  C7. Field Calibration System
  C8. UI/UX Design System (Windows)
  C9. Sync with Android App

PART D — PYTHON BRIDGE
  D1. Architecture
  D2. Command Execution
  D3. mDNS Discovery
  D4. Security

PART E — COMMUNICATION LAYER
  E1. Protocol Design
  E2. Message Specifications
  E3. WiFi (WebSocket)
  E4. Bluetooth Fallback
  E5. Three-Way Sync

PART F — UI/UX DESIGN SYSTEM (Global)
  F1. Design Philosophy
  F2. Color System
  F3. Typography
  F4. Component Library
  F5. Motion & Animation
  F6. Premium Feel Guidelines

PART G — ENGINEERING STANDARDS
  G1. Project Structure
  G2. Shared Package
  G3. Error Handling
  G4. Performance Targets
  G5. Security Model

PART H — DEVELOPMENT ROADMAP
  H1. Phase Breakdown
  H2. Priority Matrix
  H3. Risk Assessment
```

---

# PART A — PRODUCT OVERVIEW

---

## A1. Vision & Mission

**Vision:**  
A world where you have complete, invisible control over what your computer types — naturally, intelligently, and undetectably human.

**Mission:**  
Build the most sophisticated remote typing system ever made for a mobile platform. Not a toy. Not a side project. A real product that feels like it was built by a team of 20 engineers at a funded startup.

**Who is this for?**
- People who need to fill forms, tests, or documents efficiently
- Developers who want to demo code being written live
- Anyone who needs remote control over their laptop's keyboard — privately

---

## A2. Core Philosophy

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│   PHONE  =  BRAIN       LAPTOP  =  HANDS            │
│                                                     │
│   All intelligence      Dumb executor               │
│   All decisions         Just types what it's told   │
│   All AI processing     No knowledge of content     │
│   Full user control     Responds to commands only   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

| Principle | Description |
|-----------|-------------|
| **You are always in control** | Nothing types without your explicit START. Pause and Stop are always one tap away |
| **Human first** | Every character, every pause, every mistake is planned to feel human |
| **Invisible by design** | The system should be completely undetectable during operation |
| **Privacy absolute** | No data leaves your local network unless you explicitly enable cloud AI |
| **Premium without compromise** | Every screen, every interaction, every animation must feel world-class |

---

## A3. System Topology

```
                        ┌─────────────────────┐
                        │   ANDROID APP        │
                        │   (Flutter)          │
                        │                      │
                        │  • AI Engine         │
                        │  • Human Simulator   │
                        │  • Section Manager   │
                        │  • Full Control UI   │
                        └──────────┬──────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │               │
              WiFi (WS)      Bluetooth       WiFi (WS)
                    │              │               │
                    ▼              ▼               ▼
         ┌──────────────┐              ┌───────────────────┐
         │ PYTHON BRIDGE│              │  WINDOWS DESKTOP  │
         │              │              │  APP (Flutter)    │
         │ • Executes   │◄────────────►│                   │
         │   keystrokes │   localhost  │  • Full Settings  │
         │ • pyautogui  │   WebSocket  │  • Screen Overlay │
         │ • mDNS       │              │  • OCR Capture    │
         │ • Dumb slave │              │  • Calibration    │
         └──────────────┘              │  • Stealth Mode   │
                                       └───────────────────┘
```

**Three components. One system.**
- Android App → the brain you carry
- Python Bridge → the invisible typist on your laptop
- Windows App → the command center on your screen (invisible when needed)

---

## A4. Technology Decisions

### Why Flutter for both platforms?
- Single language (Dart) across Android + Windows
- Shared business logic, models, and AI engine via a common package
- Consistent UI system — same design tokens, same components
- You already know Flutter — no context switching

### Why Python for the bridge?
- `pyautogui` is the most reliable cross-platform keyboard simulation library
- Tiny footprint, easy to package as a single `.exe`
- No UI needed — pure background service
- Easy to update independently of the Flutter apps

### Why WebSocket over REST?
- Real-time, bidirectional, low latency
- Persistent connection — no reconnection overhead per message
- Natural fit for streaming character-by-character commands
- Easy to implement in both Flutter (`web_socket_channel`) and Python (`websockets`)

---

# PART B — ANDROID APP (Flutter)

---

## B1. App Architecture

The Android app follows **Clean Architecture** with feature-based folder structure.

```
Presentation Layer (Flutter Widgets + Riverpod UI state)
        ↕
Domain Layer (Use Cases + Business Logic)
        ↕
Data Layer (Repositories + Services + Local DB)
        ↕
Infrastructure (WebSocket, Bluetooth, Hive, Claude API)
```

**State Management:** Riverpod 2.x (AsyncNotifier pattern)  
**Navigation:** GoRouter  
**Dependency Injection:** Riverpod providers (no get_it needed)  
**Local DB:** Hive (NoSQL, fast, no setup)  
**Networking:** `web_socket_channel` + `flutter_blue_plus`

---

## B2. Feature Specifications — Android

### B2.1 Text Mode

**Core capability:** Type any text on laptop, with full human simulation.

**Input options:**
- Manual typing in app
- Paste from clipboard
- Voice-to-text (microphone input → text)
- Import from file (`.txt`, `.md`, `.pdf` — OCR for PDF)

**Per-section configuration:**
```
Each section has:
  ├── Content (the text to type)
  ├── Target (Tab x N / Click field name / Active window)
  ├── Mode (Normal / Code / Password / Fast-fill)
  ├── Speed Profile (Very Slow / Slow / Medium / Fast / Custom WPM)
  ├── Error Profile (rate per line + correction style)
  ├── Pre-section action (Wait Ns / Wait for tap / Keyboard shortcut)
  └── Post-section action (Wait Ns / Tab / Enter / Custom shortcut)
```

**Execution controls:**
- **START** — begins execution of command queue
- **PAUSE** — instantly freezes laptop typing (mid-character if needed)
- **RESUME** — continues from exact position
- **STOP** — ends session, resets state
- **EMERGENCY STOP** — double-tap, instant, overrides everything

**Progress tracking:**
- Current section indicator
- Characters typed / total
- Estimated time remaining
- Real-time WPM display
- Section completion checkmarks

---

### B2.2 Speed System

| Profile | WPM | Character delay | Feel |
|---------|-----|-----------------|------|
| Very Slow | 15–25 | 200–400ms | Careful student, unfamiliar text |
| Slow | 30–45 | 110–200ms | Thoughtful writer |
| Medium | 50–70 | 70–110ms | Average adult typist |
| Fast | 80–100 | 50–70ms | Experienced professional |
| Very Fast | 110–130 | 35–50ms | Power user |
| Custom | User-set | Calculated | Exact WPM target |

**Variance:** Every delay has ±15% random variance applied. No two characters are ever exactly the same speed — a flat interval is an instant giveaway of automation.

---

### B2.3 Error System

**Error Types:**
| Type | Description | Example |
|------|-------------|---------|
| Adjacent key | Nearby key on QWERTY layout | 'e' → 'r' |
| Transposition | Two adjacent chars swapped | 'the' → 'teh' |
| Double char | Extra character added | 'hello' → 'helllo' |
| Missing char | Character skipped | 'hello' → 'helo' |
| Case error | Wrong case | 'Hello' → 'hEllo' |

**Error Placement Rules (non-negotiable):**
- Never on first character of a word
- Never on very common short words (a, is, of, the, to, in, it)
- Never two consecutive errors
- Never on numbers or special characters in forms
- More frequent later in long sessions (fatigue simulation)

**Correction Styles:**
| Style | Behavior |
|-------|----------|
| Immediate | Error → backspace → correct (within 30ms) |
| Short delay | Error → 1–2 more chars → pause → backspace → correct |
| Word end | Finish word → pause → backspace back → retype |
| Sentence end | Continue → end of sentence → go back and fix |

**Customization UI:**
```
Error Rate:     [  0  ][  1  ][●2  ][  3  ][  4  ][  5  ]  per line
Correction:     [ Immediate ] [ Short delay ] [●Word end ] [ Sentence ]
Error types:    [✓] Adjacent  [✓] Transpose  [ ] Double  [✓] Missing
```

---

### B2.4 Session Templates

Save complete session configurations:
- All sections with their text + settings
- Speed and error profiles
- Field map reference
- Name + description + tags

Template library:
- Grid view with search and filter
- Import/export as `.htpl` file (JSON-based)
- Share templates with others

---

### B2.5 Session History

Optional (off by default for privacy):

Each logged session contains:
- Date, time, duration
- Total characters typed
- Which template was used
- Average WPM achieved
- Error/correction count
- Target application (Chrome, Word, etc.)

History viewer:
- Timeline view
- Replay a session (re-execute same command queue)
- Export as report

---

## B3. AI & Human Simulation Engine

This is the most critical module. Lives entirely on the Android app.

### B3.1 Execution Planner

Before any character is sent to the laptop, the planner converts raw text into a **typed command queue**:

```
Input: "Hello World"

Step 1 — Rhythm Analysis:
  Analyze character frequency, position, context

Step 2 — Error Injection Planning:
  Decide: char 7 ('o' in World) → adjacent error ('i') → correct after 2 chars

Step 3 — Delay Mapping:
  H  → 145ms (capital, start of word)
  e  → 72ms
  l  → 58ms
  l  → 74ms (double-l hesitation)
  o  → 65ms
  [SPACE] → 88ms (word boundary)
  W  → 138ms (capital)
  o  → 61ms → INJECT 'i' instead
  r  → 55ms
  l  → [pause 180ms] [backspace x3] [retype 'orl']
  d  → 62ms

Step 4 — Output: typed command queue
  [{char:'H', delay:145, type:NORMAL},
   {char:'e', delay:72,  type:NORMAL},
   ...
   {char:'i', delay:61,  type:ERROR},
   {char:'r', delay:55,  type:NORMAL},
   {special:PAUSE, duration:180},
   {special:BACKSPACE, count:3},
   {char:'o', delay:68,  type:CORRECTION},
   ...]
```

The entire queue is computed **before** execution starts. Nothing is decided mid-flight.

---

### B3.2 Humanization Patterns

**Burst typing** — common sequences typed faster:
```
Digraphs (fast):   th, er, on, an, in, re, he, nd, at, en
Trigraphs (fast):  the, and, ing, ion, ent, for, tio, ere
Common words:      is, to, of, in, it, be, as, at, by, we
```

**Slowdowns** — typed more carefully:
- First character of sentence (after `. ` or `\n`)
- Uppercase letters (Shift key involvement)
- Numbers in text context
- Uncommon/long words (length > 9 chars)
- After a paragraph break

**Thinking pauses:**
```
After period + space:    300–800ms
After comma:             80–200ms
After paragraph break:   800–2500ms
Before a new section:    500–3000ms (user-configured)
After a correction:      150–400ms (recovering from mistake)
```

---

### B3.3 Fatigue Simulation (Optional Toggle)

As session progresses past 500 words:
- Error rate increases by 10% per 200 words
- Speed decreases by 5% per 300 words
- Thinking pauses get slightly longer
- Models a real human who has been typing for a while

Toggle: ON/OFF in settings. Default: OFF.

---

### B3.4 Cloud AI Integration (Optional)

When enabled, calls **Anthropic Claude API** before building the execution plan:

**Use cases:**
1. **Natural Language Instructions** → You write: *"Fill name slowly, wait 3 seconds, then write the essay with 1 mistake every other line corrected at end of word"* → AI converts to structured section config
2. **Text Rhythm Optimization** → AI rewrites pacing hints into the text metadata
3. **Code Analysis** → AI identifies exact zones where errors are safe vs unsafe
4. **Screen OCR Processing** → AI reads captured screen text, understands context, prepares intelligent response

**Privacy:** API calls include only the text you're working with. No device info, no session history. Toggle in settings.

---

## B4. Section & Instruction System

### B4.1 Section Model

```dart
class Section {
  final String id;
  final String name;
  final String content;
  final SectionTarget target;      // Where to type
  final TypingMode mode;           // TEXT / CODE / FAST_FILL
  final SpeedProfile speed;
  final ErrorProfile errors;
  final PreAction preAction;       // What to do before typing
  final PostAction postAction;     // What to do after typing
  final bool waitForManualStart;   // Pause and wait for tap
}

class SectionTarget {
  final TargetType type;           // ACTIVE_WINDOW / TAB_N / CLICK_FIELD
  final int? tabCount;             // For TAB_N
  final String? fieldName;         // For CLICK_FIELD (from calibration)
}
```

### B4.2 Visual Section Builder (Android UI)

```
┌──────────────────────────────────────────────┐
│  + NEW SECTION                               │
├──────────────────────────────────────────────┤
│  📌 Section Name: [Essay Answer            ] │
│                                              │
│  🎯 Target:  [ Tab x 2 ▼ ]                  │
│                                              │
│  ⚡ Mode:    [ Text ▼ ]  [ Code ▼ ]          │
│                                              │
│  🚀 Speed:   ●━━━━━━━━━━━ Medium             │
│                                              │
│  ❌ Errors:  2/line  Correct: Word end       │
│                                              │
│  ⏱ Before:  Wait [ 3 ] seconds              │
│  ⏱ After:   Press [ Enter ▼ ]               │
│                                              │
│  ☑ Wait for my tap before starting          │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ My name is John and I study at the   │   │
│  │ University of Delhi. I have been...  │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  [  CANCEL  ]              [  SAVE  ✓  ]    │
└──────────────────────────────────────────────┘
```

### B4.3 Natural Language Mode

Type casual instructions, AI parses them:

**Input:**
> "First type the name slowly with zero mistakes, hit tab twice, wait 2 seconds, then type the long answer at medium speed with 1 mistake per line corrected at end of word, then press enter"

**AI Output (auto-generated sections):**
```
Section 1: Name
  Target: Active field
  Speed: Slow
  Errors: 0
  Post: Tab x2, wait 2s

Section 2: Long Answer
  Speed: Medium
  Errors: 1/line, correct at word end
  Post: Enter
```

User reviews → confirms → ready to execute.

---

## B5. Code Mode Intelligence

### B5.1 Language Detection

Auto-detected from content analysis:

| Language | Detection Signals |
|----------|------------------|
| Python | `def`, `import`, `:` line endings, indentation |
| JavaScript | `function`, `const`, `=>`, `;` endings |
| Dart | `void`, `Widget`, `class`, `@override` |
| Java | `public class`, `System.out`, `;` + `{}` |
| HTML | `<`, `>`, tag patterns |
| SQL | `SELECT`, `FROM`, `WHERE` |
| Bash | `#!/bin/bash`, `$`, pipe patterns |

Manual override always available.

---

### B5.2 Code Zone Mapping

Before typing, AI/parser maps every line into zones:

```
Zone Type          Error Allowed?   Examples
─────────────────────────────────────────────────────
SYNTAX_KEYWORD     NEVER            def, for, if, class, return
SYNTAX_OPERATOR    NEVER            =, ==, +=, ->, =>
SYNTAX_STRUCTURE   NEVER            (), [], {}, :, ;
VARIABLE_NAME      SOMETIMES        my_variable, userName, count
STRING_CONTENT     YES              "hello world", 'any text'
COMMENT            YES              # this is a comment, // note
IMPORT_PATH        NEVER            'package:flutter/material.dart'
```

### B5.3 Code Typing Rhythm

```
Before function definition:    pause 1200–2500ms (planning)
Before complex logic:          pause 400–900ms
After opening bracket:         pause 50–150ms (thinking)
Indentation (tabs/spaces):     typed fast (30–50ms each)
Keywords (def/for/if):         typed in burst (very fast)
Variable names:                medium speed with slight hesitation at capitals
Comments:                      slowest speed (composing thought)
Long lines:                    micro-pause at 40-char mark (screen scroll habit)
```

---

## B6. Connection Management

### B6.1 Discovery Flow (First Time)

```
1. User opens "Connect" in Android app
2. App broadcasts mDNS query: "_humantype._tcp.local"
3. Python bridge (running on laptop) responds with:
   {
     device_name: "My Dell Laptop",
     os: "Windows 11",
     ip: "192.168.1.45",
     port: 8765,
     bridge_version: "1.0.0"
   }
4. App shows discovered devices list
5. User selects → pairing token generated (UUID v4 + timestamp hash)
6. Token stored on both devices
7. Connection established
```

### B6.2 Auto-Connect (Every Time After)

```
App opens
  └─► Check saved devices
        └─► Ping via mDNS
              ├─► Found → Auto-connect (< 2 seconds)
              └─► Not found → Try Bluetooth
                    ├─► Found → Connect via BT
                    └─► Not found → Manual connect prompt
```

### B6.3 Connection Quality Monitor

```dart
enum ConnectionQuality {
  excellent,   // WiFi < 30ms latency    🟢
  good,        // WiFi 30–80ms           🟢
  fair,        // WiFi 80–150ms          🟡
  poor,        // WiFi > 150ms           🟠
  bluetooth,   // BT mode active         🔵
  disconnected // No connection          🔴
}
```

Shown always in app header. If quality drops mid-session, app pauses typing and shows warning.

### B6.4 Reconnection During Active Session

If connection drops while typing:
1. Typing pauses immediately (pending chars buffered)
2. App attempts reconnect (5 retries, 2s apart)
3. If reconnected: resume from exact position (queue preserved)
4. If failed: session saved as "interrupted" — can resume later

---

## B7. UI/UX Design System — Android

*(See Part F for global design system)*

### B7.1 Screen Architecture

```
App Entry
  └── Splash (animated logo, 1.5s)
        └── Onboarding (first launch only, 3 slides)
              └── Home Screen
                    ├── Connect Screen
                    ├── Text Mode
                    │     ├── Section Builder
                    │     └── Execution Screen
                    ├── Code Mode
                    │     ├── Code Input
                    │     └── Execution Screen
                    ├── Templates
                    │     ├── Template Library
                    │     └── Template Editor
                    ├── History
                    └── Settings
                          ├── Typing Defaults
                          ├── Connection
                          ├── AI Settings
                          ├── Privacy
                          └── About
```

### B7.2 Key Screen Designs

#### Home Screen
```
┌──────────────────────────────────────┐
│                              ⚙️      │
│  HumanType                           │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  🟢  My Dell Laptop            │  │
│  │      WiFi · 24ms · Excellent   │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌──────────────┐ ┌──────────────┐   │
│  │              │ │              │   │
│  │   📝 Text    │ │   💻 Code    │   │
│  │    Mode      │ │    Mode      │   │
│  │              │ │              │   │
│  └──────────────┘ └──────────────┘   │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  📋 Templates         3 saved│    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  🕐 Last Session    2h ago   │    │
│  └──────────────────────────────┘    │
│                                      │
└──────────────────────────────────────┘
```

#### Execution Screen (During Typing)
```
┌──────────────────────────────────────┐
│  ✕                      ⏸  ■        │
│                                      │
│         TYPING IN PROGRESS           │
│                                      │
│  Section  ●──────○──────○──────○     │
│           1      2      3      4     │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ "Hello my name is John and I  │  │
│  │  study at the University of D" │  │
│  │                         ↑ live │  │
│  └────────────────────────────────┘  │
│                                      │
│  ████████████████░░░░░░░░  67%       │
│                                      │
│  847 / 1,263 chars                   │
│  ~45 seconds remaining               │
│  Current speed: 68 WPM               │
│                                      │
│  ┌─────────────────────────────────┐ │
│  │         ⏸  PAUSE               │ │
│  └─────────────────────────────────┘ │
│                                      │
│  ■ STOP SESSION                      │
└──────────────────────────────────────┘
```

---

## B8. State Management

Using **Riverpod 2.x** with AsyncNotifier:

```dart
// Core providers
final connectionProvider = AsyncNotifierProvider<ConnectionNotifier, ConnectionState>
final sessionProvider = NotifierProvider<SessionNotifier, SessionState>
final executionProvider = NotifierProvider<ExecutionNotifier, ExecutionState>
final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>
final calibrationProvider = NotifierProvider<CalibrationNotifier, CalibrationState>
```

**Session State Machine:**
```
IDLE
  └─► PLANNING (building queue)
        └─► READY (queue built, waiting for START)
              └─► EXECUTING
                    ├─► PAUSED → EXECUTING
                    ├─► SECTION_BREAK (waiting for manual tap)
                    ├─► COMPLETED
                    └─► ABORTED
```

---

## B9. Local Storage

Using **Hive** (fast, encrypted, no config):

```dart
// Boxes (tables)
HiveBox<DeviceModel>      'devices'        // Paired laptops
HiveBox<SessionModel>     'sessions'       // Session history
HiveBox<TemplateModel>    'templates'      // Saved templates
HiveBox<FieldMapModel>    'field_maps'     // Calibration data
HiveBox<AppSettings>      'settings'       // User preferences
HiveBox<ErrorProfile>     'error_profiles' // Custom error configs
```

All Hive boxes encrypted with AES-256 using a device-generated key stored in Flutter Secure Storage.

---

# PART C — WINDOWS APP (Flutter Desktop)

---

## C1. App Architecture

The Windows desktop app is built with **Flutter for Windows** and shares the same Dart business logic as the Android app via the `humantype_shared` package.

**Additional Windows-specific layers:**
- `win32` package for Windows API calls
- `screen_retriever` for screenshot capture
- `tesseract_ocr` for text extraction
- `tray_manager` for system tray
- Custom overlay window with `WDA_EXCLUDEFROMCAPTURE`

---

## C2. Feature Specifications — Windows

### C2.1 Full Settings Panel

The Windows app exposes every single setting from the Android app, plus Windows-exclusive settings:

**Typing Settings:**
- Default speed profile
- Default error rate and type
- Fatigue simulation toggle
- Burst typing patterns toggle

**Connection Settings:**
- Paired Android devices list
- Auto-connect on startup toggle
- WiFi port configuration
- Bluetooth toggle

**Overlay Settings:**
- Overlay position (save last position)
- Default opacity (20–100%)
- Auto-collapse delay (3s / 5s / 10s / Never)
- Collapse trigger (mouse away / timer / manual)
- Keyboard shortcut customization
- Stealth mode hotkey

**AI Settings:**
- Claude API key input
- AI features toggle (per feature)
- Privacy: what data is sent to API

**Session Settings:**
- History logging toggle
- Auto-save templates toggle
- Replay behavior

**Advanced:**
- Bridge port override
- WDA compatibility check
- Process name in stealth mode
- Log level (for debugging)

---

### C2.2 Live Dashboard

Main screen of the Windows app:

```
┌─────────────────────────────────────────────────────────────────┐
│  HumanType Desktop                    🟢 Connected · 24ms  ─□✕ │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─── STATUS ──────────────────────────────────────────────┐   │
│  │  Android App: Connected (iPhone 14 Pro)                 │   │
│  │  Bridge:      Running (port 8765)                       │   │
│  │  Active App:  Google Chrome — forms.google.com          │   │
│  │  Field Map:   Loaded (3 fields)                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─── CURRENT SESSION ─────────────────────────────────────┐   │
│  │                                                         │   │
│  │  Section 2 of 4 · Text Mode · Medium · 2 errors/line   │   │
│  │                                                         │   │
│  │  ████████████░░░░░░░░░░  52%  ·  624/1,200 chars       │   │
│  │                                                         │   │
│  │  "My name is John and I study at the University of D"  │   │
│  │                                                    ↑live│   │
│  │                                                         │   │
│  │  [ ⏸ PAUSE ]     [ ■ STOP ]     [ → SKIP SECTION ]    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─── QUICK ACTIONS ───────────────────────────────────────┐   │
│  │  📷 Capture Screen     🎯 Calibrate     🕶 Stealth Mode │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## C3. Screen Overlay System

### C3.1 What Is The Overlay?

A **secondary Flutter window** — not a widget inside the main app, but a completely separate window that:
- Floats above all other windows (`HWND_TOPMOST`)
- Has no title bar, no borders, click-through background
- Is draggable from its visible elements
- Is **excluded from all screen capture** via Windows API

This is different from an in-app overlay. It is a real, independent OS-level window.

---

### C3.2 Overlay Lifecycle

```
Windows App launches
  └─► Bridge confirms running
        └─► Overlay window spawned (separate Flutter window)
              └─► WDA_EXCLUDEFROMCAPTURE set immediately
                    └─► Overlay appears in corner of screen
                          └─► Collapsed by default
```

**Overlay persists** even if the main Windows app window is closed (main app minimizes to tray, overlay stays).

**Overlay closes** only when:
- User explicitly closes it from tray menu
- Stealth mode hides it (it doesn't close, it becomes 12px dot)
- App fully quits

---

### C3.3 Overlay States & UI

#### State 1: Collapsed (Default)
```
┌──────────────────┐
│ 🟢 HT      ≡    │
└──────────────────┘
Width: 120px, Height: 36px
Corner: Top-right (default, movable)
```

#### State 2: Expanded (tap ≡)
```
┌───────────────────────┐
│  🟢 HumanType    ─    │
├───────────────────────┤
│  Section 2 / 4        │
│  ████████░░  67%      │
├───────────────────────┤
│  ▶  START             │
│  ⏸  PAUSE            │
│  ■  STOP              │
├───────────────────────┤
│  Speed   [━●━━━] Med  │
│  Errors  [━━●━] 2/ln  │
├───────────────────────┤
│  📷  Capture Screen   │
│  ⚙️   Open Settings   │
│  🕶   Stealth Mode    │
├───────────────────────┤
│  Next: Section 3      │
│  ETA: ~38 seconds     │
└───────────────────────┘
Width: 220px, Height: dynamic
```

#### State 3: Stealth Mode
```
●   (12x12px green dot, semi-transparent)
```
Only visual indicator that system is running. Clickable — expands to small status popup (also excluded from capture).

#### State 4: Disconnected
```
┌──────────────────┐
│ 🔴 Disconnected  │
└──────────────────┘
```
Pulses red. Click to reconnect.

---

### C3.4 Overlay Interaction Details

**Dragging:**
- Drag from anywhere on the overlay panel
- Snaps to screen edges and corners when released close to them
- Position saved to disk, restored on next launch

**Keyboard Shortcuts:**
| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+H` | Toggle expand/collapse |
| `Ctrl+Shift+S` | Toggle stealth mode |
| `Ctrl+Shift+P` | Pause/Resume typing |
| `Ctrl+Shift+X` | Emergency stop |
| `Ctrl+Shift+C` | Capture screen (OCR) |

**Opacity:**
- Right-click on overlay → opacity slider
- Range: 20% (very faint) to 100% (fully opaque)
- Only affects your view — still excluded from capture at any opacity

---

## C4. WDA_EXCLUDEFROMCAPTURE — Deep Technical Dive

### C4.1 How Windows Screen Capture Works

```
Physical Screen Output:
GPU renders → DWM (Desktop Window Manager) composites → Monitor

Screen Recording APIs (what recorders use):
  ├── BitBlt (legacy GDI) → reads from DWM composition
  ├── DXGI Desktop Duplication → reads from DWM output
  └── Windows Graphics Capture (WGC) → modern, used by OBS, Game Bar, Zoom
```

All three paths go through **DWM**. DWM is the gatekeeper.

### C4.2 What the Flag Does

```c
SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE); // 0x00000011
```

This tells DWM:

> *"When compositing for the monitor, include this window normally. When compositing for any capture API request, replace this window's pixels with transparent/black."*

DWM maintains **two composition trees**:
- **Display tree** → what you see on monitor (includes overlay)
- **Capture tree** → what capture APIs see (overlay replaced with nothing)

This happens at the compositor level — no software can bypass it from userspace.

### C4.3 Flutter Implementation

```dart
// overlay_window.dart
import 'package:win32/win32.dart';
import 'dart:ffi';

class OverlayWindowManager {

  static void applyExcludeFromCapture(int hwnd) {
    // WDA_EXCLUDEFROMCAPTURE = 0x00000011
    final result = SetWindowDisplayAffinity(hwnd, 0x00000011);
    if (result == 0) {
      // Failed — check Windows version
      _handleCompatibilityFailure();
    }
  }

  static void applyAlwaysOnTop(int hwnd) {
    SetWindowPos(
      hwnd,
      HWND_TOPMOST,
      0, 0, 0, 0,
      SWP_NOMOVE | SWP_NOSIZE,
    );
  }

  static void removeTaskbarPresence(int hwnd) {
    // Remove from taskbar and Alt+Tab
    final exStyle = GetWindowLongPtr(hwnd, GWL_EXSTYLE);
    SetWindowLongPtr(hwnd, GWL_EXSTYLE,
      exStyle | WS_EX_TOOLWINDOW & ~WS_EX_APPWINDOW);
  }

  static void _handleCompatibilityFailure() {
    // Windows version < 10 v2004
    // Show one-time warning to user
    // Overlay still works but will be visible in recordings
  }

  static bool checkCompatibility() {
    // Check Windows build number >= 19041 (v2004)
    // Return true if WDA_EXCLUDEFROMCAPTURE is supported
  }
}
```

### C4.4 What Can and Cannot Bypass It

| Capture Method | Sees Overlay? | Notes |
|----------------|--------------|-------|
| OBS Studio | ❌ No | Uses WGC/DXGI |
| Windows Game Bar | ❌ No | Uses WGC |
| Zoom screen share | ❌ No | Uses WGC |
| Google Meet share | ❌ No | Uses WGC |
| Microsoft Teams share | ❌ No | Uses WGC |
| ShareX | ❌ No | Uses WGC/DXGI |
| Bandicam | ❌ No | Uses DXGI |
| Windows Snipping Tool | ❌ No | Uses WGC |
| `PrintScreen` key | ❌ No | Goes through DWM |
| Phone camera at screen | ✅ Yes | Physical camera bypasses OS |
| External HDMI capture card | ✅ Yes | Captures GPU output directly |
| Remote desktop (RDP) | ✅ Yes | Different rendering path |

**Bottom line:** Every software-based capture method is blocked. Only physical hardware can see it.

### C4.5 Windows Version Requirements

| Windows Version | Build | WDA Support |
|----------------|-------|-------------|
| Windows 11 (all) | 22000+ | ✅ Full support |
| Windows 10 v21H2 | 19044 | ✅ Full support |
| Windows 10 v21H1 | 19043 | ✅ Full support |
| Windows 10 v20H2 | 19042 | ✅ Full support |
| Windows 10 v2004 | 19041 | ✅ Full support |
| Windows 10 v1909 | 18363 | ❌ Not supported |
| Windows 10 v1903 | 18362 | ❌ Not supported |
| Windows 7/8/8.1 | — | ❌ Not supported |

App shows compatibility warning at launch on unsupported versions.

---

## C5. Stealth / Demo Mode

### C5.1 Full Stealth Activation Sequence

When you activate Stealth Mode:

```
Step 1: Main Windows app window → minimize to system tray (no taskbar)
Step 2: System tray icon → change to neutral icon (no HumanType branding)
Step 3: Overlay → collapse to 12x12px green dot
Step 4: Process display name → change to "RuntimeHost" in Task Manager
Step 5: Bridge process → already named "RuntimeBridge" (set at startup)
Step 6: All non-essential background services → suspend
Step 7: Confirmation sent to Android app → phone shows "Stealth Active" badge
```

### C5.2 What Each Viewer Sees

**Physical viewer in same room:**
- Sees normal computer screen
- Text appears to type itself, human-like
- Tiny green dot in corner (if not hidden)
- Nothing else visible

**Screen recording:**
- Captures everything except the overlay (WDA flag)
- No HumanType UI visible at all
- Just the target application with text being typed

**Tech-savvy viewer (checking Task Manager):**
- Sees "RuntimeHost" process (not "HumanType")
- WebSocket port 8765 active (but any app could use any port)
- No obvious fingerprint

### C5.3 Demo Mode Presentation Guide

**Recommended demo flow:**
1. Pre-load your session on Android (text, sections, settings)
2. Activate Stealth Mode on Windows
3. Open your target app (browser, notepad, Word)
4. Begin demo — show the app, navigate naturally
5. When ready, tap START on phone (hidden in pocket or face-down)
6. Text starts appearing on screen — human-like, natural
7. Audience sees only the clean screen

**You can explain:**
> "I have an app that can type this for me automatically, and it looks completely human. Let me show you..."
> (without revealing HOW or showing the settings)

---

## C6. Screen OCR & Capture System

### C6.1 Capture Flow

```
User clicks "📷 Capture" (overlay or Windows app)
  └─► Overlay hides itself (300ms) — not in capture
        └─► Screenshot taken of:
              ├── Active window only (default)
              ├── Full screen
              └── User-selected region
                    └─► OCR processing (local, offline)
                          └─► Extracted text sent to Android via WebSocket
                                └─► Android AI processes text
                                      └─► Prepares response / section
                                            └─► User reviews on phone → START
```

### C6.2 OCR Engine

**Primary:** Windows OCR API (`Windows.Media.Ocr`) — built into Windows, no install needed, high quality, works offline.

**Fallback:** Tesseract OCR — open source, runs locally, supports 100+ languages.

**Processing:**
- Strip UI chrome (buttons, scrollbars) — only extract text content
- Preserve structure (paragraphs, line breaks, lists)
- Identify question/answer format if present
- Return clean, structured text to Android

### C6.3 Smart Capture Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| Active Window | Only foreground app content | Forms, documents |
| Full Screen | Everything visible | Overview of context |
| Region Select | Drag to select area | Specific question/field |
| Field Auto-Detect | AI finds all input fields | Multi-field forms |

---

## C7. Field Calibration System

### C7.1 Live Screen Calibration

The Windows app shows a **live mirror** of your screen inside its calibration panel:

```
┌──────────────────────────────────────────────────────────┐
│  Field Calibration          [Chrome — google.com/forms]  │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌───────────────────────────────────────────────────┐   │
│  │  [Live screenshot of your screen, refreshes 2/s]  │   │
│  │                                                   │   │
│  │   Name: [___________________________] ← click here│   │
│  │                             ↑                     │   │
│  │                      Red crosshair                │   │
│  │   Email:[___________________________]             │   │
│  │                                                   │   │
│  └───────────────────────────────────────────────────┘   │
│                                                          │
│  Fields mapped:                                          │
│  ✅ Field 1: "Name"    → (452, 312)                      │
│  ✅ Field 2: "Email"   → (452, 398)                      │
│  ⬜ Field 3: (click to add)                              │
│                                                          │
│  [  SAVE FIELD MAP  ]              [  CLEAR ALL  ]       │
└──────────────────────────────────────────────────────────┘
```

### C7.2 Field Map Storage

```dart
class FieldMap {
  final String id;
  final String appName;        // "Google Chrome"
  final String windowTitle;    // "Google Forms — My Survey"
  final String? urlPattern;    // "forms.google.com/d/*"
  final List<MappedField> fields;
  final DateTime createdAt;
  final DateTime lastUsed;
}

class MappedField {
  final String name;           // "Name", "Email", "Answer 1"
  final double xPercent;       // X position as % of screen width
  final double yPercent;       // Y position as % of screen height
  // Stored as percentages to handle resolution changes
}
```

### C7.3 Auto-Load Field Maps

When active window changes on laptop:
1. Bridge detects new window title + URL (if browser)
2. Sends window info to Windows app
3. Windows app checks field map database
4. If match found → auto-loads → sends to Android
5. Android shows: "Field map loaded: Google Forms — 3 fields"

---

## C8. UI/UX Design System — Windows

*(See Part F for global design system)*

### C8.1 Windows App Layout

```
┌────────────────────────────────────────────────────────────────┐
│  HumanType                                           ─  □  ✕  │
├──────────┬─────────────────────────────────────────────────────┤
│          │                                                      │
│  🏠      │                                                      │
│  Home    │              CONTENT AREA                           │
│          │                                                      │
│  📝      │   (Dashboard / Settings / Calibration / History)    │
│  Session │                                                      │
│          │                                                      │
│  🎯      │                                                      │
│  Calibr. │                                                      │
│          │                                                      │
│  📋      │                                                      │
│  Templt. │                                                      │
│          │                                                      │
│  🕐      │                                                      │
│  History │                                                      │
│          │                                                      │
│  ⚙️      │                                                      │
│  Settings│                                                      │
│          │                                                      │
└──────────┴─────────────────────────────────────────────────────┘
```

**Sidebar:** 60px icon-only, expands to 220px on hover with labels.

### C8.2 Windows-Specific UI Principles

- **Mica material** background (Windows 11 acrylic-like effect via custom Flutter rendering)
- **Fluent Design** influence — depth, motion, acrylic where appropriate
- Minimum window size: 900x600px
- Responsive: adapts layout for wider/narrower windows
- Dark mode by default, follows Windows system theme setting

---

## C9. Sync Between Android and Windows App

### C9.1 Sync Scope

| Data | Sync Direction | Trigger |
|------|---------------|---------|
| Session start/pause/stop | Both ↔ Both | User action on either device |
| Speed/error settings change | Both ↔ Both | User changes on either device |
| Section progress | Bridge → Windows → Android | Bridge reports progress |
| Field map loaded | Windows → Android | Window focus change |
| Capture OCR result | Windows → Android | Capture button pressed |
| Stealth mode toggle | Android ↔ Windows | User toggles on either |
| Connection status | Bridge → Both | Connection state changes |

### C9.2 Sync Protocol

The three components (Android, Windows App, Bridge) form a **local mesh**:

```
Android App ◄──────────────► Windows App
     │                            │
     └──────────────────────────► Bridge
                (all via WebSocket on local network)
```

Android ↔ Windows App sync goes directly via WebSocket (not through Bridge).
Bridge is only for command execution + progress reporting.

---

# PART D — PYTHON BRIDGE

---

## D1. Architecture

The Python bridge is a **minimal, single-purpose service**. It does one thing: receive commands and execute keystrokes.

```
main.py
  ├── Start mDNS broadcast
  ├── Start WebSocket server (port 8765)
  ├── Start Bluetooth server (if BT available)
  ├── Start system tray icon
  └── Wait for connections

On connection:
  ├── Validate pairing token
  └── Start command loop:
        Receive command → parse → execute → send ACK
```

---

## D2. Command Execution

```python
# executor/keyboard_executor.py

import pyautogui
import asyncio

pyautogui.FAILSAFE = False  # Disable corner-move emergency stop
pyautogui.PAUSE = 0         # We control all delays ourselves

class KeyboardExecutor:

    async def execute(self, command: dict):
        cmd_type = command['type']

        if cmd_type == 'CHAR':
            await asyncio.sleep(command['delay_ms'] / 1000)
            pyautogui.write(command['char'], interval=0)

        elif cmd_type == 'SPECIAL_KEY':
            await asyncio.sleep(command['delay_ms'] / 1000)
            pyautogui.press(command['key'])

        elif cmd_type == 'HOTKEY':
            pyautogui.hotkey(*command['keys'])

        elif cmd_type == 'CLICK':
            pyautogui.click(command['x'], command['y'])

        elif cmd_type == 'PAUSE':
            # Do nothing — hold the queue
            pass
```

---

## D3. mDNS Discovery

```python
# discovery/mdns_broadcast.py
from zeroconf import ServiceInfo, Zeroconf
import socket

def broadcast():
    info = ServiceInfo(
        "_humantype._tcp.local.",
        f"HumanType Bridge._humantype._tcp.local.",
        addresses=[socket.inet_aton(get_local_ip())],
        port=8765,
        properties={
            'device': socket.gethostname(),
            'os': platform.system(),
            'version': '1.0.0'
        }
    )
    zeroconf = Zeroconf()
    zeroconf.register_service(info)
    return zeroconf  # Keep reference to unregister on exit
```

---

## D4. Security

```python
# security/token_validator.py

import hashlib
import hmac

class TokenValidator:

    def validate(self, received_token: str, stored_token: str) -> bool:
        # Constant-time comparison (prevents timing attacks)
        return hmac.compare_digest(
            received_token.encode(),
            stored_token.encode()
        )

    def generate_pairing_token(self, device_id: str) -> str:
        # SHA-256 of device_id + timestamp + random salt
        salt = os.urandom(32).hex()
        raw = f"{device_id}:{int(time.time())}:{salt}"
        return hashlib.sha256(raw.encode()).hexdigest()
```

---

# PART E — COMMUNICATION LAYER

---

## E1. Protocol Design

All messages are **JSON over WebSocket**. Simple, debuggable, universal.

```json
{
  "version": "1.0",
  "type": "MESSAGE_TYPE",
  "id": "unique-message-id",
  "timestamp": 1700000000000,
  "payload": { ... }
}
```

---

## E2. Message Specifications

### Handshake
```json
{
  "type": "HANDSHAKE",
  "payload": {
    "device_id": "uuid-v4",
    "device_name": "Pixel 8 Pro",
    "device_type": "android",
    "app_version": "1.0.0",
    "pairing_token": "sha256hash"
  }
}
```

### Command (most frequent message)
```json
{
  "type": "CMD",
  "payload": {
    "action": "CHAR",
    "char": "h",
    "delay_pre_ms": 85
  }
}
```

### Session Control
```json
{
  "type": "SESSION_CONTROL",
  "payload": {
    "action": "PAUSE" | "RESUME" | "ABORT" | "COMPLETE"
  }
}
```

### Progress Report (Bridge → Apps)
```json
{
  "type": "PROGRESS",
  "payload": {
    "chars_sent": 847,
    "chars_total": 1263,
    "section_index": 1,
    "sections_total": 4,
    "current_wpm": 68,
    "eta_seconds": 45
  }
}
```

### OCR Capture Result (Windows → Android)
```json
{
  "type": "OCR_RESULT",
  "payload": {
    "text": "Extracted text from screen...",
    "source": "active_window",
    "app_name": "Google Chrome",
    "window_title": "Question 3 of 10"
  }
}
```

### Sync Message (Settings change)
```json
{
  "type": "SETTINGS_SYNC",
  "payload": {
    "changed_key": "typing.speed_profile",
    "new_value": "fast",
    "source_device": "android"
  }
}
```

---

## E3. WiFi (WebSocket)

- **Port:** 8765 (configurable)
- **Library (Python):** `websockets` 12.x
- **Library (Flutter):** `web_socket_channel` 2.x
- **Heartbeat:** Ping every 5s, timeout after 15s
- **Reconnect:** Automatic, exponential backoff (1s, 2s, 4s, 8s, max 30s)

---

## E4. Bluetooth Fallback

- **Protocol:** RFCOMM (Classic Bluetooth, not BLE — BLE too slow for real-time)
- **Library (Python):** `PyBluez`
- **Library (Flutter):** `flutter_blue_plus`
- **Latency:** ~30–50ms (vs WiFi ~10–30ms) — acceptable for typing
- **Auto-switch:** If WiFi drops → auto-switch to BT → continue session
- **Auto-switch back:** If WiFi recovers → switch back (seamless)

---

## E5. Three-Way Sync Architecture

```
                 Android App
                /            \
               /              \
     WebSocket                WebSocket
             /                  \
            /                    \
   Python Bridge  ──localhost──  Windows App
```

- Android ↔ Bridge: execution commands + progress
- Android ↔ Windows: settings sync + OCR results + status
- Windows ↔ Bridge: local WebSocket (same machine, ultra-low latency)

All three maintain their own connection state. Any two can communicate directly without the third.

---

# PART F — UI/UX DESIGN SYSTEM (Global)

---

## F1. Design Philosophy

HumanType's visual identity is built on four pillars:

**1. Dark Precision**
Dark-first design. The interface disappears into the background — your content and controls are what matters. Like a professional audio mixing board or a trading terminal.

**2. Information Density Done Right**
Every pixel earns its place. No padding for padding's sake. No decorative elements. But not cramped — comfortable density, like a well-designed IDE.

**3. Motion With Purpose**
Animations exist to communicate state, not to impress. Typing progress breathes. Status changes slide. Sections complete with satisfying micro-feedback. Every animation has a functional reason.

**4. Control Clarity**
At any moment, the user must instantly know: what is happening right now, what can I do, and how do I stop it. Especially the last one.

---

## F2. Color System

### Base Palette
```
Background Primary:    #0A0A0F   (near-black, blue tint)
Background Secondary:  #111118   (slightly lighter)
Background Elevated:   #1A1A24   (cards, panels)
Background Overlay:    #22222E   (modals, sheets)

Border Subtle:         #2A2A3A
Border Default:        #3A3A4E
Border Strong:         #5A5A7A
```

### Brand Colors
```
Accent Primary:    #6C63FF   (electric violet — the brand color)
Accent Secondary:  #4ECDC4   (teal — secondary actions)
Accent Tertiary:   #FF6B6B   (coral — danger/stop)
```

### Semantic Colors
```
Success:    #2ECC71   (connected, complete, correct)
Warning:    #F39C12   (fair connection, caution)
Error:      #E74C3C   (disconnected, failed, stop)
Info:       #3498DB   (informational states)
```

### Connection Status Colors
```
Excellent:    #2ECC71   🟢
Good:         #27AE60   🟢
Fair:         #F39C12   🟡
Poor:         #E67E22   🟠
Bluetooth:    #3498DB   🔵
Disconnected: #E74C3C   🔴
```

### Typing Progress
```
Typing active:    #6C63FF (animated gradient)
Section complete: #2ECC71
Error character:  #E74C3C (brief flash)
Correction:       #F39C12 (brief flash)
```

---

## F3. Typography

```
Primary Font:     Inter (variable weight — 300 to 700)
Monospace Font:   JetBrains Mono (code display, live typing preview)
```

### Type Scale
```
Display:     32sp / Bold    — Screen titles
Heading 1:   24sp / SemiBold — Section titles
Heading 2:   18sp / SemiBold — Card titles
Body Large:  16sp / Regular  — Primary content
Body:        14sp / Regular  — Default text
Body Small:  12sp / Regular  — Secondary info
Caption:     11sp / Medium   — Labels, timestamps
Mono Large:  16sp / Regular  — Live typing display
Mono:        13sp / Regular  — Code display
```

---

## F4. Component Library

### Connection Status Chip
```
┌─────────────────────────────┐
│  ●  My Dell Laptop   24ms   │
└─────────────────────────────┘
Pill shape, 36px height
Left dot: animated pulse when connected
Color: matches connection quality
```

### Section Card
```
┌──────────────────────────────────┐
│  02  Essay Answer          ⋮    │
│      Text · Medium · 2 err/ln   │
│  ──────────────────────────────  │
│  My name is John and I study... │
└──────────────────────────────────┘
Subtle left border in accent color
Number badge top-left
Drag handle right (reorder)
```

### Progress Bar (Typing)
```
████████████░░░░░░░░  67%
```
- Gradient fill (accent → lighter accent)
- Animated shimmer while active
- Snaps cleanly at section boundaries
- Green when complete

### Control Buttons
```
Primary (START):   Filled, accent color, 48dp height, full-width
Secondary (PAUSE): Outlined, accent border, same height
Danger (STOP):     Filled, red, same height
```

All buttons have:
- 200ms press animation (scale down 96%)
- Haptic feedback on Android
- Disabled state (40% opacity, no interaction)

### Speed Slider
```
Slow ──────●────────── Fast
           ↑
        68 WPM
```
Custom track with labeled endpoints. Thumb shows current value. Snaps to preset positions with haptic.

---

## F5. Motion & Animation

### Timing Functions
```
Quick:      150ms  ease-out    (button presses, toggles)
Standard:   250ms  ease-in-out (panel transitions)
Deliberate: 400ms  ease-in-out (screen transitions)
Slow:       600ms  ease-in-out (onboarding, first launch)
```

### Key Animations

**Typing progress:** Progress bar fills smoothly, character by character. No jumping.

**Section complete:** Section card gets green checkmark with a subtle scale+fade animation. Next section card slides up.

**Error flash:** Character preview briefly flashes red → orange → normal. 200ms total.

**Connection established:** Status chip pulses once green. A subtle success toast slides in from top.

**Pause state:** Progress bar gets animated dashed pattern (like a paused download). Pulsing.

**Stealth mode activate:** Main window slides down and fades out. Tray icon morphs. Overlay shrinks with easing.

---

## F6. Premium Feel Guidelines

These are the rules that separate a premium product from an average one:

1. **Never show raw error states.** Always wrap errors in friendly, actionable messages with a clear next step.

2. **Loading states for everything.** Any action that takes >100ms shows a loading indicator. Instant feedback always.

3. **Consistent spacing grid.** 4px base unit. All spacing is multiples of 4 (4, 8, 12, 16, 24, 32, 48).

4. **No orphaned text.** No label without a value, no value without context.

5. **Empty states are designed.** The templates screen when empty has an illustration and a CTA, not a blank screen.

6. **Every tap does something visible.** Ripple effect, scale, color change — always confirm the interaction.

7. **Typography hierarchy is strict.** Never two elements at the same visual weight in competition.

8. **Icons are consistent.** Use a single icon family throughout (Phosphor Icons — filled style).

9. **Destructive actions require confirmation.** Stop session, delete template, clear history — always a confirmation step.

10. **Settings are organized by mental model, not technical model.** Users think "how fast does it type" not "WPM configuration parameter."

---

# PART G — ENGINEERING STANDARDS

---

## G1. Project Structure

```
humantype/
│
├── packages/
│   └── humantype_shared/           ← Shared Dart package
│       ├── lib/
│       │   ├── models/             ← Data models (used by both apps)
│       │   ├── protocols/          ← WebSocket message definitions
│       │   ├── ai_engine/          ← Human simulation + AI logic
│       │   │   ├── execution_planner.dart
│       │   │   ├── humanizer.dart
│       │   │   ├── error_injector.dart
│       │   │   └── claude_api_service.dart
│       │   ├── connection/         ← Connection management logic
│       │   └── constants/
│       └── pubspec.yaml
│
├── apps/
│   ├── humantype_android/          ← Flutter Android App
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── core/
│   │   │   │   ├── router.dart
│   │   │   │   ├── theme.dart
│   │   │   │   └── providers.dart
│   │   │   └── features/
│   │   │       ├── home/
│   │   │       ├── text_mode/
│   │   │       │   ├── screens/
│   │   │       │   ├── widgets/
│   │   │       │   └── providers/
│   │   │       ├── code_mode/
│   │   │       ├── templates/
│   │   │       ├── history/
│   │   │       ├── connect/
│   │   │       └── settings/
│   │   └── pubspec.yaml
│   │
│   └── humantype_windows/          ← Flutter Windows App
│       ├── lib/
│       │   ├── main.dart
│       │   ├── core/
│       │   └── features/
│       │       ├── dashboard/
│       │       ├── overlay/
│       │       │   ├── overlay_window.dart
│       │       │   ├── overlay_ui.dart
│       │       │   └── wda_manager.dart
│       │       ├── ocr/
│       │       ├── calibration/
│       │       ├── stealth/
│       │       ├── settings/
│       │       └── sync/
│       ├── windows/                ← Win32 native files
│       └── pubspec.yaml
│
└── bridge/
    └── humantype_bridge/           ← Python Bridge
        ├── main.py
        ├── server/
        │   ├── websocket_server.py
        │   └── bluetooth_server.py
        ├── executor/
        │   ├── keyboard_executor.py
        │   └── command_parser.py
        ├── discovery/
        │   └── mdns_broadcast.py
        ├── security/
        │   └── token_validator.py
        ├── tray/
        │   └── tray_icon.py
        ├── requirements.txt
        └── build.spec               ← PyInstaller config → single .exe
```

---

## G2. Shared Package

`humantype_shared` is a pure Dart package — no Flutter dependency. Importable by both apps.

Key exports:
```dart
// Models
export 'models/section_model.dart';
export 'models/session_model.dart';
export 'models/template_model.dart';
export 'models/field_map_model.dart';
export 'models/device_model.dart';

// AI Engine
export 'ai_engine/execution_planner.dart';
export 'ai_engine/humanizer.dart';
export 'ai_engine/error_injector.dart';

// Protocol
export 'protocols/message_types.dart';
export 'protocols/ws_message.dart';

// Connection
export 'connection/connection_manager.dart';
export 'connection/mdns_discovery.dart';
```

---

## G3. Error Handling

**Principles:**
- Every async operation wrapped in try-catch
- Errors classified: Recoverable / Non-recoverable
- User always sees friendly message, never raw exception
- All errors logged locally (never sent anywhere)

**Error taxonomy:**
```
ConnectionError
  ├── WiFiNotAvailable
  ├── DeviceNotFound
  ├── AuthenticationFailed
  └── ConnectionLost (during session → auto-recover)

SessionError
  ├── QueueEmpty
  ├── InvalidSection
  └── ExecutionFailed

BridgeError
  ├── PyAutoGuiFailed (rare, OS-level)
  └── WindowNotFound
```

---

## G4. Performance Targets

| Metric | Target |
|--------|--------|
| App startup to home screen | < 2 seconds |
| Connect to known device (WiFi) | < 2 seconds |
| Command latency (phone → laptop keystroke) | < 50ms |
| Execution planner (1000 chars) | < 200ms |
| OCR capture to result on phone | < 3 seconds |
| Overlay show/hide animation | 60fps, < 16ms frame time |
| Memory usage (Android app) | < 150MB |
| Memory usage (Windows app) | < 200MB |
| Bridge CPU usage (idle) | < 0.5% |
| Bridge CPU usage (typing) | < 5% |

---

## G5. Security Model

**Local-first:** No data ever leaves the local network by default.

**Authentication:** Every connection verified by SHA-256 pairing token. Tokens are device-pair-specific and regenerated on re-pairing.

**Encryption:** All local WebSocket traffic can be upgraded to WSS (TLS). Default: plaintext (local network, low risk). Option to enable in settings.

**Data at rest:** Hive database encrypted with AES-256. Key stored in platform secure storage (Android Keystore / Windows DPAPI).

**Cloud AI (optional):** Only text content sent to Anthropic API. No device info, no identifiers, no session metadata.

**Bridge hardening:**
- Accepts only from authenticated paired devices
- Rate limit: max 2000 commands/minute
- Automatic disconnect on 3 failed auth attempts
- No incoming connections from outside local subnet

---

# PART H — DEVELOPMENT ROADMAP

---

## H1. Phase Breakdown

### Phase 1 — Skeleton (Weeks 1–3)
**Goal:** All three components exist and can talk to each other.

- [ ] Python bridge: WebSocket server + pyautogui basic typing
- [ ] Flutter Android: Connect screen + manual IP entry + send text
- [ ] Flutter Windows: Basic app shell + connect to bridge
- [ ] Shared package: Basic models + message protocol
- [ ] Simple text → type (no humanization)

**Milestone:** Type "Hello World" on laptop from phone via WiFi.

---

### Phase 2 — Human Engine (Weeks 4–7)
**Goal:** Typing feels genuinely human.

- [ ] Execution planner (full command queue builder)
- [ ] Humanizer (rhythm, burst patterns, pauses)
- [ ] Error injector (all error types + correction styles)
- [ ] Speed profiles (5 presets + custom WPM)
- [ ] Pause / Resume / Stop (real-time, precise)
- [ ] Fatigue simulation (optional)

**Milestone:** Type a 500-word essay that a human can't distinguish from real typing.

---

### Phase 3 — Section System (Weeks 8–10)
**Goal:** Multi-section sessions work end to end.

- [ ] Section model + builder UI (Android)
- [ ] Section execution queue
- [ ] Pre/post actions (Tab, Enter, wait, shortcuts)
- [ ] Manual section start (tap to proceed)
- [ ] Progress tracking (per section + overall)

**Milestone:** Fill a 4-field form from phone, each field with different settings.

---

### Phase 4 — Code Mode (Weeks 11–12)
**Goal:** Code typing is intelligent and realistic.

- [ ] Language detector
- [ ] Code zone mapper (syntax vs safe zones)
- [ ] Code typing rhythm (pauses, burst, indent handling)
- [ ] Code-specific error rules
- [ ] Code mode UI (Android)

**Milestone:** Type a 50-line Python function that looks hand-written.

---

### Phase 5 — Connection & Discovery (Weeks 13–14)
**Goal:** Zero-friction connection experience.

- [ ] mDNS broadcast (Python bridge)
- [ ] mDNS discovery (Android + Windows)
- [ ] Auto-connect on app launch
- [ ] Bluetooth fallback (Android + Python)
- [ ] Auto-switch WiFi ↔ Bluetooth
- [ ] Reconnect during active session

**Milestone:** Open app → automatically connected in under 2 seconds.

---

### Phase 6 — Windows App + Overlay (Weeks 15–18)
**Goal:** Full Windows desktop experience.

- [ ] Flutter Windows app (full UI)
- [ ] Overlay window (separate Flutter window)
- [ ] WDA_EXCLUDEFROMCAPTURE implementation
- [ ] Overlay states (collapsed, expanded, stealth, disconnected)
- [ ] Stealth / Demo mode (full activation sequence)
- [ ] Android ↔ Windows sync
- [ ] Keyboard shortcuts for overlay

**Milestone:** Overlay visible on screen, completely invisible in OBS recording.

---

### Phase 7 — OCR + Calibration (Weeks 19–21)
**Goal:** Screen reading and field mapping work.

- [ ] Screenshot capture (Windows)
- [ ] OCR (Windows OCR API + Tesseract fallback)
- [ ] Send OCR result to Android
- [ ] Live screen mirror for calibration (Windows)
- [ ] Field map storage + auto-load
- [ ] Window focus detection

**Milestone:** Capture a question from screen, AI prepares answer, types it.

---

### Phase 8 — AI Layer (Weeks 22–24)
**Goal:** Cloud AI features working.

- [ ] Claude API integration
- [ ] Natural language instruction parsing → sections
- [ ] AI-assisted OCR analysis
- [ ] AI code zone analysis
- [ ] Privacy controls for AI features

**Milestone:** Tell app in plain English what to do → it sets up sections automatically.

---

### Phase 9 — Polish & Production (Weeks 25–28)
**Goal:** Product-quality finish.

- [ ] Full design system implementation (all screens)
- [ ] Onboarding flow
- [ ] Empty states, error states, loading states
- [ ] Templates library (Android + Windows)
- [ ] Session history
- [ ] Performance optimization
- [ ] Edge case handling (all scenarios from Section G3)
- [ ] Bridge packaging (PyInstaller → single .exe)
- [ ] Testing on Windows 10 + 11, multiple screen sizes

**Milestone:** Give to 3 beta testers. No confusion, no crashes, no ugly screens.

---

## H2. Priority Matrix

| Feature | Impact | Effort | Priority |
|---------|--------|--------|---------|
| Basic typing (WiFi) | 🔴 Critical | Low | P0 |
| Human simulation engine | 🔴 Critical | High | P0 |
| Start/Pause/Stop | 🔴 Critical | Low | P0 |
| Section system | 🔴 Critical | Medium | P0 |
| mDNS auto-connect | 🟡 High | Medium | P1 |
| Code mode | 🟡 High | High | P1 |
| Windows desktop app | 🟡 High | High | P1 |
| Screen overlay + WDA | 🟡 High | High | P1 |
| Stealth/Demo mode | 🟡 High | Medium | P1 |
| Bluetooth fallback | 🟡 High | Medium | P1 |
| OCR screen capture | 🟢 Medium | Medium | P2 |
| Field calibration | 🟢 Medium | Medium | P2 |
| Claude AI integration | 🟢 Medium | Medium | P2 |
| Templates | 🟢 Medium | Low | P2 |
| Session history | 🟢 Medium | Low | P2 |
| Fatigue simulation | 🔵 Low | Low | P3 |
| Voice input | 🔵 Low | Medium | P3 |
| Mouse control | 🔵 Low | Medium | P3 |
| Multi-device | 🔵 Low | High | P4 |

---

## H3. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| WDA flag not working on older Windows | Medium | High | Version check at startup, clear warning |
| Bluetooth reliability | Medium | Medium | WiFi is primary, BT is just fallback |
| pyautogui fails in certain apps | Low | High | Test suite across major apps; fallback methods |
| OCR accuracy on complex screens | Medium | Low | Feature is supplementary, manual fallback always exists |
| Windows Defender flags bridge .exe | Medium | High | Code signing certificate for release build |
| mDNS blocked by firewall | Low | Medium | Manual IP entry always available as fallback |
| Claude API rate limits | Low | Low | Queue API calls, local fallback always works |

---

*HumanType — Complete Product System Design*  
*Version 3.0 | Production Blueprint | A to Z*

*"Your words. Your control. Indistinguishable from human."*

---
---

# PART I — BIDIRECTIONAL ARCHITECTURE (v4.0 — NEW)

> **Core Upgrade:** HumanType is no longer a one-way remote control.
> It is a **bidirectional intelligent mesh** — any device can be a controller,
> any device can be an executor. Direction is a setting, not a limitation.

---

## I1. Why Bidirectional?

### Current (v1 — One Direction):
```
Phone ──commands──► Laptop (types)
```
This works. But it's limiting. What if:
- You want to **control your phone from your laptop**? (type on phone via laptop keyboard)
- You want your **phone to read its own screen** and send that to laptop?
- You want **two laptops** — one controller, one executor?
- You're at a desk and want laptop to be the brain, not the phone?

### Future (v2 — Any Direction):
```
Phone   ◄──────────────────────► Laptop
         controller OR executor    controller OR executor
         (decided at runtime)      (decided at runtime)
```

**The architecture must support this from day one** — even if the features aren't built yet. Retrofitting bidirectionality later is painful and breaks everything.

---

## I2. Device Role System

Every HumanType device has a **role** at any point in time. Roles are dynamic — they can switch.

```dart
enum DeviceRole {
  controller,   // Sends commands, holds AI engine, controls session
  executor,     // Receives commands, executes them on local OS
  both,         // Simultaneously controlling one device + executing for another
  passive,      // Connected but not active in current session (observer/monitor)
}
```

### Role Assignment

Roles are negotiated at session start, not hardcoded at install time:

```
Session Setup:
  Device A says: "I want to be Controller"
  Device B says: "I will be Executor"
  → Session begins

OR:

  Device A says: "I want to be Both"
  (controlling Device B while Device C executes for Device A)
  → Multi-device session begins
```

### Role Capabilities Per Device

| Capability | Android | Windows | Notes |
|-----------|---------|---------|-------|
| Be a Controller | ✅ Now | ✅ Now | Both can send commands |
| Be an Executor | ✅ Future | ✅ Now (via Bridge) | Android executor = type on phone |
| Be Both | ✅ Future | ✅ Future | Advanced multi-device |
| Run AI Engine | ✅ Always | ✅ Always | Both have full AI |
| Host Bridge | ❌ | ✅ (Python) | Only Windows has pyautogui |
| OCR Capture | ✅ Future | ✅ Now | Android camera OCR future |

---

## I3. Bidirectional Protocol Design

### The Key Design Decision: Role-Tagged Messages

Every message in the protocol carries **who is sending** and **what role they currently hold**:

```json
{
  "version": "1.0",
  "type": "CMD",
  "id": "uuid",
  "timestamp": 1700000000,
  "sender": {
    "device_id": "phone-uuid",
    "device_type": "android",
    "current_role": "controller"
  },
  "target": {
    "device_id": "laptop-uuid",
    "device_type": "windows"
  },
  "payload": { ... }
}
```

This means:
- Any device can send any message type
- Receiving device checks if sender has permission for that message
- No hardcoded "phone sends, laptop receives" assumption anywhere in the codebase

### Message Routing Layer

Every app has a **MessageRouter** that decides what to do with incoming messages:

```dart
class MessageRouter {

  void route(WsMessage message) {
    final myRole = sessionManager.currentRole;

    switch (message.type) {

      case MessageType.CMD:
        if (myRole == DeviceRole.executor || myRole == DeviceRole.both) {
          // I am executor — execute this command
          commandExecutor.execute(message.payload);
        } else {
          // I am not executor — relay or reject
          _handleUnexpectedCommand(message);
        }

      case MessageType.SESSION_CONTROL:
        // Any device can receive session control
        sessionManager.handleControl(message.payload);

      case MessageType.ROLE_CHANGE:
        // Role negotiation message
        _handleRoleChange(message);

      case MessageType.CAPABILITY_QUERY:
        // Another device asking what I can do
        _respondWithCapabilities(message.sender);
    }
  }
}
```

### Capability Advertisement

When devices connect, they immediately exchange capabilities:

```json
{
  "type": "CAPABILITY_ADVERTISEMENT",
  "payload": {
    "can_be_controller": true,
    "can_be_executor": true,
    "has_ai_engine": true,
    "has_keyboard_control": false,
    "has_ocr": false,
    "has_camera": true,
    "has_overlay": false,
    "platform": "android",
    "app_version": "1.0.0",
    "protocol_version": "1.0"
  }
}
```

Each device advertises what it CAN do. The other device decides what role to assign.

---

## I4. Current Flows (v1 — Phone → Laptop)

These are what we build first. Fully working in v1.

```
┌──────────────────────────────────────────────────────────────┐
│                    CURRENT FLOWS (v1)                        │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Flow 1: Basic Typing                                        │
│  Phone (Controller) ──CMD──► Bridge (Executor) → Types      │
│                                                              │
│  Flow 2: Settings Sync                                       │
│  Phone ◄──SYNC──► Windows App (both update each other)      │
│                                                              │
│  Flow 3: OCR Capture                                         │
│  Windows App ──CAPTURE──► OCR ──RESULT──► Phone (AI reads)  │
│                                                              │
│  Flow 4: Progress Reporting                                  │
│  Bridge ──PROGRESS──► Windows App ──SYNC──► Phone            │
│                                                              │
│  Flow 5: Session Control                                     │
│  Phone OR Windows App ──CONTROL──► Bridge (pause/stop)       │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

Note: **Flow 5 is already bidirectional** — both phone AND windows app can control the bridge. This is the foundation.

---

## I5. Future Flows (v2 — Laptop → Phone & Beyond)

These are designed NOW, built LATER. The protocol supports them from day one.

### Flow A: Laptop Controls Phone (v2)
```
Windows App (Controller)
  └──► Phone App (Executor)
         └──► Types into active Android app
              (WhatsApp, Gmail, any text field on phone)
```

**Use case:** You're at your desk, laptop is more convenient to type on. You want to fill something on your phone without picking it up.

**What needs to be built:**
- Android "Executor Mode" — receives CMD messages, uses Android Accessibility Service to inject keystrokes into active app
- Windows "Controller Mode" — UI to compose text + sections for phone target

### Flow B: Phone Camera → Laptop (v2)
```
Phone Camera (captures physical document/whiteboard)
  └──► OCR on phone
         └──► Text sent to Windows App
                └──► Types extracted text on laptop
```

**Use case:** You have a printed document, scan it with phone camera, laptop types it out.

### Flow C: Phone → Phone (v2)
```
Phone A (Controller) ──► Phone B (Executor)
```
**Use case:** One person controls another person's phone typing. Remote assistance, accessibility help.

### Flow D: Full Reverse — Laptop Reads, Phone Executes (v2)
```
Windows OCR captures screen text
  └──► AI on Windows analyzes it
         └──► Sends answer to Phone
                └──► Phone types it into its own active app
```

### Flow E: Daisy Chain (v3 — Advanced)
```
Phone ──► Laptop A ──► Laptop B
(Controller)  (relay)  (executor)
```

---

## I6. Scalability: N-Device Mesh

The architecture is designed to eventually support **any number of devices** in a session.

### Device Registry

Every session has a **Device Registry** — a live list of all connected devices and their roles:

```dart
class DeviceRegistry {
  final Map<String, ConnectedDevice> devices = {};

  // Add device when it connects
  void register(ConnectedDevice device) {
    devices[device.id] = device;
    _broadcastRegistryUpdate();
  }

  // Remove when disconnected
  void unregister(String deviceId) {
    devices.remove(deviceId);
    _broadcastRegistryUpdate();
  }

  // Assign role
  void assignRole(String deviceId, DeviceRole role) {
    devices[deviceId]?.currentRole = role;
    _broadcastRoleChange(deviceId, role);
  }

  // Query — find all executors
  List<ConnectedDevice> getExecutors() =>
    devices.values.where((d) => d.currentRole == DeviceRole.executor).toList();
}
```

### Multi-Executor Sessions (Future)

Send same command to multiple executors simultaneously:

```
Phone (Controller)
  ├──► Laptop A (Executor) — types in Word
  └──► Laptop B (Executor) — types in browser
       (both type same text simultaneously)
```

Use case: Filling same form on multiple computers at once.

### Session Bus Architecture

For N-device support, one device acts as **Session Host** (the message bus):

```
                  Session Host
                (any device, elected)
                /       |        \
               /        |         \
        Phone A      Laptop      Phone B
     (controller)  (executor)  (observer)
```

Session Host:
- Maintains device registry
- Routes messages between devices
- Handles role negotiation
- Elected automatically (highest-capability connected device)
- Re-elected if current host disconnects

---

## I7. Feature Expansion Map

This shows how the bidirectional architecture enables future features:

```
CURRENT (Phone→Laptop):              FUTURE (Any→Any):
─────────────────────────            ──────────────────────────────
✅ Type on laptop from phone    →    📱 Type on phone from laptop
✅ Control laptop keyboard      →    💻 Control phone from laptop
✅ OCR: laptop screen → phone   →    📷 OCR: phone camera → laptop
✅ Settings sync both ways      →    🔄 Full state sync all devices
✅ Pause/Stop from either       →    🎛 Full session control any device
                                     🖱 Mouse control phone → laptop
                                     📲 Notification relay laptop → phone
                                     🔊 Audio/TTS any direction
                                     📁 File transfer between devices
                                     🖥 Remote screen view (read-only)
```

---

## I8. Android as Executor (Future Implementation)

When Android acts as executor, it needs to inject keystrokes into other apps. This requires:

**Android Accessibility Service:**
```dart
// Android executor mode
class HumanTypeAccessibilityService extends AccessibilityService {

  @override
  void onAccessibilityEvent(AccessibilityEvent event) {
    // Monitor active app and focused text field
  }

  void typeCharacter(String char, int delayMs) async {
    await Future.delayed(Duration(milliseconds: delayMs));

    // Find focused input field
    final node = rootInActiveWindow?.findFocus(
      AccessibilityNodeInfo.FOCUS_INPUT
    );

    // Inject text
    final args = Bundle();
    args.putCharSequence(
      AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE,
      char
    );
    node?.performAction(
      AccessibilityNodeInfo.ACTION_SET_TEXT,
      args
    );
  }
}
```

**Limitation:** Android Accessibility Service cannot simulate individual keystrokes with human-like delays as precisely as pyautogui. It works but is less flexible. This is why Windows/Python is the preferred executor for now.

---

## I9. Windows as Controller (Future Implementation)

When Windows app acts as controller (sending commands to phone):

```dart
// Windows controller sending to phone executor
class WindowsController {

  final DeviceRegistry registry;
  final ExecutionPlanner planner;

  Future<void> startSession(SessionConfig config) async {
    // Find phone executors
    final phoneExecutors = registry.getExecutors()
      .where((d) => d.platform == 'android')
      .toList();

    if (phoneExecutors.isEmpty) {
      throw NoExecutorAvailableException();
    }

    // Build command queue (same AI engine, same planner)
    final queue = await planner.buildQueue(config);

    // Send to phone executor(s)
    for (final device in phoneExecutors) {
      await connectionManager.sendQueue(device.id, queue);
    }
  }
}
```

The AI engine, human simulator, and execution planner are **identical** whether the target is a laptop or a phone. Only the transport and the executor change.

---

## I10. Backward Compatibility Guarantee

**Rule:** Every future version of HumanType must be able to communicate with every previous version.

### How We Guarantee This:

**1. Protocol versioning in every message:**
```json
{ "version": "1.0", ... }
```
Devices negotiate the highest common protocol version they both support.

**2. Capability-first design:**
Before any session, devices exchange capabilities. If a feature isn't supported, it's gracefully skipped — never crashes.

**3. Unknown message handling:**
```dart
void handleUnknownMessage(WsMessage message) {
  // Log it, ignore it, send back "unsupported" response
  // NEVER crash
  log.warning('Unknown message type: ${message.type}');
  sendResponse(MessageType.UNSUPPORTED, message.id);
}
```

**4. Feature flags in protocol:**
New features are gated behind feature flags. Old devices see the flag as unknown and ignore it. New devices use it.

**5. Semantic versioning for protocol:**
- `1.x` — Minor features, fully backward compatible
- `2.x` — Breaking changes, negotiation required
- Old device + new device connecting: fall back to highest common version

### Version Compatibility Matrix

| Android App | Windows App | Bridge | Compatible? |
|------------|-------------|--------|-------------|
| v1.0 | v1.0 | v1.0 | ✅ Full |
| v1.0 | v1.5 | v1.0 | ✅ Full (v1.5 features hidden) |
| v1.0 | v2.0 | v1.0 | ✅ Partial (v1 features only) |
| v2.0 | v2.0 | v1.0 | ⚠️ Bridge needs update for v2 features |
| v2.0 | v2.0 | v2.0 | ✅ Full |

---

## I11. Implementation Strategy — Bidirectional in v1

Even in v1 (current build), we make these foundational decisions that cost almost nothing now but save massive refactoring later:

### What to build in v1 that enables v2:

| Decision | v1 Cost | v2 Benefit |
|----------|---------|-----------|
| Add `sender` + `target` fields to every message | Tiny | Full routing works |
| Add `current_role` field to device model | Tiny | Role system ready |
| Build `MessageRouter` class (even if simple now) | Small | Router just gets more cases added |
| Add `CAPABILITY_ADVERTISEMENT` message handling | Small | Device registry works |
| Store device capabilities in `DeviceRegistry` | Small | Multi-device ready |
| Keep AI engine in `humantype_shared` package | Already planned | Same engine reused both ways |
| Use `target.device_id` in all commands | Tiny | Routing works without changes |

**Total extra cost in v1: ~3–5 days of work.**  
**Cost of retrofitting in v2 without this: weeks of refactoring + breaking changes.**

---

## I12. Updated System Topology (v4)

```
╔══════════════════════════════════════════════════════════════════╗
║              HUMANTYPE DEVICE MESH (v4 Architecture)            ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║   ┌─────────────────┐          ┌─────────────────────────────┐  ║
║   │   ANDROID APP   │          │      WINDOWS APP            │  ║
║   │                 │          │                             │  ║
║   │ Role: Controller│◄────────►│ Role: Controller            │  ║
║   │    (current)    │  Sync    │      (future: also this)    │  ║
║   │                 │          │                             │  ║
║   │ Role: Executor  │          │ Role: Executor              │  ║
║   │   (future)      │          │   (via Bridge, current)     │  ║
║   │                 │          │                             │  ║
║   │ AI Engine ✅    │          │ AI Engine ✅                │  ║
║   │ Human Sim ✅    │          │ Human Sim ✅                │  ║
║   └────────┬────────┘          └──────────────┬──────────────┘  ║
║            │                                  │                  ║
║            │         WiFi / BT                │                  ║
║            └──────────────────────────────────┘                  ║
║                              │                                   ║
║                              │ localhost WebSocket               ║
║                              │                                   ║
║                   ┌──────────▼──────────┐                       ║
║                   │   PYTHON BRIDGE     │                       ║
║                   │                     │                       ║
║                   │ Role: Executor only │                       ║
║                   │ (current + future)  │                       ║
║                   │                     │                       ║
║                   │ pyautogui (keyboard)│                       ║
║                   │ pyautogui (mouse)   │ ← future              ║
║                   └─────────────────────┘                       ║
║                                                                  ║
║   ┌──────────────────────────────────────────────────────────┐  ║
║   │  FUTURE DEVICES (plug into same mesh, zero changes)      │  ║
║   │  • Second Android phone    • Mac (future bridge)         │  ║
║   │  • Linux laptop            • iPad (future)               │  ║
║   └──────────────────────────────────────────────────────────┘  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## I13. Updated Development Phases (with Bidirectional Foundation)

### Phase 1 — Skeleton + Bidirectional Foundation (Weeks 1–3)

Same as before, PLUS:
- [ ] Implement `MessageRouter` class in shared package
- [ ] Add `sender`, `target`, `current_role` to all message models
- [ ] Implement `CAPABILITY_ADVERTISEMENT` exchange on connect
- [ ] Implement `DeviceRegistry` (start simple — just 2 devices)
- [ ] All messages use role-tagged format from day one

**Cost:** +3 days on top of Phase 1 original scope  
**Benefit:** Everything from Part I is now possible without breaking changes

### Phase 2–8 — Unchanged
All phases remain the same. Bidirectional foundation is transparent to feature development.

### Phase 9 (New) — Bidirectional v2 Features (Future, After v1 Launch)
- [ ] Android Executor Mode (Accessibility Service)
- [ ] Windows as Controller (send commands to phone)
- [ ] Phone Camera → OCR → Laptop typing
- [ ] Multi-device session support
- [ ] Session Host election algorithm
- [ ] N-device mesh testing

---

*HumanType — Complete Product System Design*
*Version 4.0 | Production Blueprint | Bidirectional & Scalable*

*"Your words. Your control. Any device. Any direction."*