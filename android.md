# HumanType — AGENT 1: Android APK
### *Build Specification for Flutter Android App*

**Version:** 4.0  
**Your Role:** Build the **Flutter Android App** (the Brain + Controller)  
**Parallel Agent:** Agent 2 is simultaneously building the Windows App + Python Bridge  

---

> ⚠️ **READ THIS FIRST — COORDINATION RULES**
>
> You are Agent 1. Agent 2 is building the Windows App + Python Bridge.
> 
> **Shared contract between both agents:**
> - All WebSocket messages use the protocol defined in PART E (included below)
> - All data models are in `packages/humantype_shared/` — define them here, Agent 2 imports them
> - WebSocket server runs on laptop port **8765** (Agent 2 owns the server, you own the client)
> - mDNS service name: `_humantype._tcp.local` (Agent 2 broadcasts, you discover)
> - Pairing token: SHA-256, exchanged on first connect (you generate, Agent 2 validates)
> - Every message includes `sender.device_id`, `sender.current_role`, `target.device_id`
> - On connect, both sides send `CAPABILITY_ADVERTISEMENT` message immediately
>
> **You own:** `apps/humantype_android/` + `packages/humantype_shared/`  
> **Agent 2 owns:** `apps/humantype_windows/` + `bridge/humantype_bridge/`  
> **Shared package:** You define it. Agent 2 imports it. Coordinate model changes carefully.

---

## Your Deliverable

A production-quality **Flutter Android APK** that:

1. Connects to the laptop (WiFi primary, Bluetooth fallback)
2. Takes text input + section configuration from the user
3. Runs the human simulation AI engine entirely on-device
4. Sends character-by-character commands to the Python Bridge on the laptop
5. Gives the user full real-time control (Start / Pause / Resume / Stop)
6. Syncs settings bidirectionally with the Windows Desktop App
7. Receives OCR results from the Windows App and processes them with AI
8. Feels like a premium, polished product — not a prototype

---

## Project Structure (Your Part)

```
humantype/
│
├── packages/
│   └── humantype_shared/              ← YOU OWN THIS
│       ├── lib/
│       │   ├── models/
│       │   │   ├── section_model.dart
│       │   │   ├── session_model.dart
│       │   │   ├── template_model.dart
│       │   │   ├── field_map_model.dart
│       │   │   ├── device_model.dart
│       │   │   └── connected_device.dart
│       │   ├── protocols/
│       │   │   ├── ws_message.dart        ← Message wrapper model
│       │   │   ├── message_types.dart     ← All MessageType enums
│       │   │   └── capability_model.dart  ← Device capabilities
│       │   ├── ai_engine/
│       │   │   ├── execution_planner.dart ← Builds command queue
│       │   │   ├── humanizer.dart         ← Rhythm + delay engine
│       │   │   ├── error_injector.dart    ← Error placement logic
│       │   │   ├── code_analyzer.dart     ← Code zone mapping
│       │   │   └── claude_api_service.dart← Optional cloud AI
│       │   ├── connection/
│       │   │   ├── message_router.dart    ← Bidirectional routing
│       │   │   ├── device_registry.dart   ← Connected device list
│       │   │   └── mdns_discovery.dart    ← Find laptop on network
│       │   └── constants/
│       │       ├── app_constants.dart
│       │       └── protocol_constants.dart
│       └── pubspec.yaml
│
└── apps/
    └── humantype_android/             ← YOU OWN THIS
        ├── lib/
        │   ├── main.dart
        │   ├── core/
        │   │   ├── router.dart        ← GoRouter navigation
        │   │   ├── theme.dart         ← Full design system
        │   │   └── providers.dart     ← Root Riverpod providers
        │   └── features/
        │       ├── home/
        │       │   ├── screens/home_screen.dart
        │       │   └── widgets/connection_status_chip.dart
        │       ├── connect/
        │       │   ├── screens/connect_screen.dart
        │       │   ├── providers/connection_provider.dart
        │       │   └── services/
        │       │       ├── wifi_service.dart
        │       │       └── bluetooth_service.dart
        │       ├── text_mode/
        │       │   ├── screens/
        │       │   │   ├── text_mode_screen.dart
        │       │   │   └── execution_screen.dart
        │       │   ├── widgets/
        │       │   │   ├── section_card.dart
        │       │   │   └── section_builder_sheet.dart
        │       │   └── providers/
        │       │       ├── session_provider.dart
        │       │       └── execution_provider.dart
        │       ├── code_mode/
        │       │   ├── screens/code_mode_screen.dart
        │       │   └── providers/code_session_provider.dart
        │       ├── templates/
        │       │   ├── screens/templates_screen.dart
        │       │   └── providers/templates_provider.dart
        │       ├── history/
        │       │   └── screens/history_screen.dart
        │       └── settings/
        │           ├── screens/settings_screen.dart
        │           └── providers/settings_provider.dart
        ├── android/
        └── pubspec.yaml
```

---

## pubspec.yaml — Android App

```yaml
name: humantype_android
description: HumanType — Intelligent Remote Typing Controller

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.16.0'

dependencies:
  flutter:
    sdk: flutter

  # Shared package
  humantype_shared:
    path: ../../packages/humantype_shared

  # State management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Navigation
  go_router: ^13.0.0

  # Networking
  web_socket_channel: ^2.4.0

  # Bluetooth
  flutter_blue_plus: ^1.31.13

  # Local database
  hive_flutter: ^1.1.0
  hive: ^2.2.3

  # Secure storage
  flutter_secure_storage: ^9.0.0

  # mDNS discovery
  multicast_dns: ^0.3.2+1

  # UI
  google_fonts: ^6.1.0

  # Utilities
  uuid: ^4.3.3
  crypto: ^3.0.3
  intl: ^0.19.0
  permission_handler: ^11.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
  flutter_lints: ^3.0.0
```

---

## pubspec.yaml — Shared Package

```yaml
name: humantype_shared
description: Shared models, AI engine, and protocol for HumanType

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  # No Flutter dependency — pure Dart
  uuid: ^4.3.3
  crypto: ^3.0.3
  http: ^1.2.0        # For Claude API calls
  hive: ^2.2.3

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
  lints: ^3.0.0
```

---

# PART A — PRODUCT OVERVIEW (Shared Context)

---

## A1. Vision & Mission

**HumanType** is a Flutter-based remote typing system. The Android app is the brain — it holds all intelligence, makes all decisions, and gives the user complete control. The laptop types what the phone tells it to, character by character, in a way that is indistinguishable from human typing.

**Product Tagline:** *"Your words. Your control. Any device. Any direction."*

---

## A2. Core Philosophy

```
PHONE  =  BRAIN          LAPTOP  =  HANDS
All intelligence         Dumb executor
All decisions            Types what it's told
Full user control        No knowledge of content
AI processing            Responds to commands only
```

| Principle | Meaning |
|-----------|---------|
| **You are always in control** | Nothing types without your explicit START |
| **Human first** | Every character, pause, mistake is planned to feel human |
| **Invisible by design** | System undetectable during operation |
| **Privacy absolute** | No data leaves local network by default |
| **Premium without compromise** | Every screen must feel world-class |

---

## A3. System Topology

```
┌─────────────────────────────────────┐
│         ANDROID APP (YOU BUILD)     │
│                                     │
│  AI Engine + Human Simulator        │
│  Section Manager + Full Control UI  │
│  Role: Controller (current)         │
│  Role: Executor (future)            │
└──────────────┬──────────────────────┘
               │
    ┌──────────┴──────────┐
    │ WiFi (WS) primary   │
    │ Bluetooth fallback  │
    └──────────┬──────────┘
               │
    ┌──────────┴──────────────────────┐
    │  LAPTOP (Agent 2 builds)        │
    │                                 │
    │  Python Bridge → types text     │
    │  Windows Flutter App → settings │
    │  Screen Overlay → your HUD      │
    └─────────────────────────────────┘
```

---

## A4. Bidirectional Design (Build This From Day 1)

Even though v1 is Phone→Laptop only, the architecture must support future bidirectional communication. This costs ~3 extra days now and saves weeks of refactoring later.

**Every device has a role:**
```dart
enum DeviceRole {
  controller,   // Sends commands, holds AI
  executor,     // Receives + executes commands
  both,         // Future: controlling one while executing for another
  passive,      // Observer/monitor only
}
```

**Every message is role-tagged:**
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
    "device_id": "laptop-bridge-uuid",
    "device_type": "bridge"
  },
  "payload": { ... }
}
```

**On connect, immediately send capabilities:**
```json
{
  "type": "CAPABILITY_ADVERTISEMENT",
  "payload": {
    "can_be_controller": true,
    "can_be_executor": false,
    "has_ai_engine": true,
    "has_keyboard_control": false,
    "has_ocr": false,
    "has_camera": true,
    "platform": "android",
    "app_version": "1.0.0",
    "protocol_version": "1.0"
  }
}
```

---

# PART B — ANDROID APP (Flutter) — YOUR FULL BUILD SPEC

---

## B1. App Architecture

**Pattern:** Clean Architecture + Feature-first folder structure  
**State:** Riverpod 2.x (AsyncNotifier pattern)  
**Navigation:** GoRouter  
**DB:** Hive (encrypted)

```
Presentation Layer    → Flutter Widgets + Riverpod UI state
       ↕
Domain Layer          → Use Cases + Business Logic
       ↕
Data Layer            → Repositories + Services
       ↕
Infrastructure        → WebSocket, Bluetooth, Hive, Claude API
```

### Session State Machine
```
IDLE
  └─► PLANNING         (building command queue from text)
        └─► READY      (queue built, waiting for user to tap START)
              └─► EXECUTING
                    ├─► PAUSED          → EXECUTING (on resume)
                    ├─► SECTION_BREAK   (waiting for manual tap)
                    ├─► COMPLETED       (all sections done)
                    └─► ABORTED         (user stopped)
```

---

## B2. Feature Specifications — Android

### B2.1 Text Mode

**Input methods:**
- Manual typing in text area
- Paste from clipboard
- Voice-to-text (microphone)
- Import `.txt` / `.md` file

**Per-section config (every section has all of these):**
```dart
class Section {
  final String id;
  final String name;
  final String content;
  final SectionTarget target;       // WHERE to type
  final TypingMode mode;            // TEXT / CODE / FAST_FILL
  final SpeedProfile speed;
  final ErrorProfile errors;
  final PreAction preAction;        // What to do BEFORE typing
  final PostAction postAction;      // What to do AFTER typing
  final bool waitForManualStart;    // Pause and wait for user tap
}

class SectionTarget {
  final TargetType type;            // ACTIVE_WINDOW / TAB_N / CLICK_FIELD
  final int? tabCount;
  final String? fieldName;          // From calibration map
}

enum TypingMode { text, code, fastFill }
```

**Pre/Post Actions:**
```dart
enum PreActionType { none, waitSeconds, waitForTap, pressKey, pressHotkey }
enum PostActionType { none, waitSeconds, pressEnter, pressTab, pressHotkey }
```

---

### B2.2 Speed System

| Profile | WPM | Character delay | Feel |
|---------|-----|-----------------|------|
| Very Slow | 15–25 | 200–400ms | Careful student |
| Slow | 30–45 | 110–200ms | Thoughtful writer |
| Medium | 50–70 | 70–110ms | Average adult |
| Fast | 80–100 | 50–70ms | Experienced typist |
| Very Fast | 110–130 | 35–50ms | Power user |
| Custom | Any | Calculated | Exact WPM |

**CRITICAL:** Every delay has ±15% random variance. Flat intervals are immediately detectable as automation.

---

### B2.3 Error System

**Error Types:**
| Type | Description | Example |
|------|-------------|---------|
| Adjacent key | Nearby key on QWERTY | 'e' typed as 'r' |
| Transposition | Two chars swapped | 'the' → 'teh' |
| Double char | Extra letter | 'hello' → 'helllo' |
| Missing char | Char skipped | 'hello' → 'helo' |
| Case error | Wrong case | 'Hello' → 'hEllo' |

**Error Placement Rules (enforce strictly):**
- NEVER on first character of a word
- NEVER on very short common words: a, is, of, the, to, in, it, be, as
- NEVER two consecutive errors
- NEVER on numbers or email addresses
- More likely late in long sessions (fatigue simulation)

**Correction Styles:**
| Style | Behavior |
|-------|----------|
| Immediate | Error → backspace → correct (within 30ms) |
| Short delay | Error → 1–2 more chars → backspace → correct |
| Word end | Finish word → backspace → retype |
| Sentence end | Continue → end of sentence → go back and fix |

---

### B2.4 Session Templates

- Save complete session (all sections + settings) as named template
- Template format: `.htpl` (JSON internally)
- Import/Export templates
- Template library with search + filter

---

### B2.5 Session History (Optional, off by default)

Per session log:
- Date, time, duration
- Total chars, WPM achieved
- Error/correction count
- Target app name
- Template used

---

## B3. AI & Human Simulation Engine

**Location:** `packages/humantype_shared/lib/ai_engine/`  
**Language:** Pure Dart, no Flutter dependency  
**Used by:** Android app (primary), Windows app (via shared package)

---

### B3.1 Execution Planner

The planner converts raw text + section config into a **complete command queue** before execution starts. Nothing is decided mid-execution.

```dart
// execution_planner.dart

class ExecutionPlanner {

  Future<List<TypeCommand>> buildQueue(List<Section> sections) async {
    final queue = <TypeCommand>[];

    for (final section in sections) {
      // 1. Pre-action commands
      queue.addAll(_buildPreActionCommands(section.preAction));

      // 2. Humanized text commands
      final humanized = await _humanize(section);
      queue.addAll(humanized);

      // 3. Post-action commands
      queue.addAll(_buildPostActionCommands(section.postAction));
    }

    return queue;
  }

  Future<List<TypeCommand>> _humanize(Section section) async {
    final text = section.content;
    final commands = <TypeCommand>[];

    // Step 1: Rhythm analysis
    final rhythmMap = Humanizer.analyzeRhythm(text, section.speed);

    // Step 2: Error injection planning
    final errorPlan = ErrorInjector.createPlan(
      text,
      section.errors,
      section.mode,
    );

    // Step 3: Merge into command queue
    for (int i = 0; i < text.length; i++) {
      final delay = rhythmMap[i];
      final error = errorPlan[i];

      if (error != null) {
        commands.addAll(_buildErrorSequence(text[i], error, delay));
      } else {
        commands.add(TypeCommand.char(text[i], delay));
      }
    }

    return commands;
  }
}
```

**TypeCommand model:**
```dart
class TypeCommand {
  final CommandType type;     // CHAR, SPECIAL_KEY, HOTKEY, PAUSE, CLICK
  final String? char;         // For CHAR type
  final String? key;          // For SPECIAL_KEY (enter, tab, backspace)
  final List<String>? keys;   // For HOTKEY (ctrl+s)
  final int delayMs;          // Delay before this command
  final int? x, y;            // For CLICK type
  final bool isError;         // Tracking only
  final bool isCorrection;    // Tracking only

  // Factory constructors
  factory TypeCommand.char(String c, int delay) => ...
  factory TypeCommand.backspace(int delay) => ...
  factory TypeCommand.key(String k, int delay) => ...
  factory TypeCommand.hotkey(List<String> keys) => ...
  factory TypeCommand.pause(int durationMs) => ...
  factory TypeCommand.click(int x, int y) => ...
}
```

---

### B3.2 Humanizer (Rhythm Engine)

```dart
// humanizer.dart

class Humanizer {

  static Map<int, int> analyzeRhythm(String text, SpeedProfile speed) {
    final delays = <int, int>{};
    final baseDelay = speed.baseDelayMs;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      int delay = baseDelay;

      // Apply contextual modifiers
      delay = _applyCapitalModifier(char, delay);
      delay = _applyWordBoundaryModifier(text, i, delay);
      delay = _applyBurstModifier(text, i, delay);
      delay = _applyPunctuationPause(char, delay);
      delay = _applyVariance(delay);  // ±15% random

      delays[i] = delay;
    }

    return delays;
  }

  // Capitals take longer (Shift key involvement)
  static int _applyCapitalModifier(String char, int delay) {
    if (char == char.toUpperCase() && char != char.toLowerCase()) {
      return (delay * 1.4).round();
    }
    return delay;
  }

  // Word boundaries have micro-pauses
  static int _applyWordBoundaryModifier(String text, int i, int delay) {
    if (i > 0 && text[i - 1] == ' ') {
      return (delay * 1.2).round();
    }
    return delay;
  }

  // Common digraphs typed faster (muscle memory)
  static const _fastDigraphs = ['th', 'er', 'on', 'an', 'in', 're', 'he', 'nd'];
  static const _fastTrigraphs = ['the', 'and', 'ing', 'ion', 'ent', 'for'];

  static int _applyBurstModifier(String text, int i, int delay) {
    if (i >= 1) {
      final digraph = text.substring(i - 1, i + 1).toLowerCase();
      if (_fastDigraphs.contains(digraph)) return (delay * 0.7).round();
    }
    if (i >= 2) {
      final trigraph = text.substring(i - 2, i + 1).toLowerCase();
      if (_fastTrigraphs.contains(trigraph)) return (delay * 0.65).round();
    }
    return delay;
  }

  // Punctuation causes thinking pause
  static int _applyPunctuationPause(String char, int delay) {
    switch (char) {
      case '.': return delay + _randomInRange(300, 800);
      case ',': return delay + _randomInRange(80, 200);
      case '\n': return delay + _randomInRange(400, 1200);
      default: return delay;
    }
  }

  // ±15% variance — critical for human feel
  static int _applyVariance(int delay) {
    final variance = (delay * 0.15).round();
    return delay + _randomInRange(-variance, variance);
  }

  static int _randomInRange(int min, int max) {
    return min + (Random().nextInt(max - min));
  }
}
```

---

### B3.3 Error Injector

```dart
// error_injector.dart

class ErrorInjector {

  // QWERTY adjacency map — keys physically near each other
  static const Map<String, List<String>> _adjacentKeys = {
    'q': ['w', 'a'],       'w': ['q', 'e', 'a', 's'],
    'e': ['w', 'r', 's', 'd'], 'r': ['e', 't', 'd', 'f'],
    't': ['r', 'y', 'f', 'g'], 'y': ['t', 'u', 'g', 'h'],
    'u': ['y', 'i', 'h', 'j'], 'i': ['u', 'o', 'j', 'k'],
    'o': ['i', 'p', 'k', 'l'], 'p': ['o', 'l'],
    'a': ['q', 'w', 's', 'z'], 's': ['a', 'd', 'w', 'e', 'z', 'x'],
    'd': ['s', 'f', 'e', 'r', 'x', 'c'], 'f': ['d', 'g', 'r', 't', 'c', 'v'],
    'g': ['f', 'h', 't', 'y', 'v', 'b'], 'h': ['g', 'j', 'y', 'u', 'b', 'n'],
    'j': ['h', 'k', 'u', 'i', 'n', 'm'], 'k': ['j', 'l', 'i', 'o', 'm'],
    'l': ['k', 'o', 'p'],   'z': ['a', 's', 'x'],
    'x': ['z', 's', 'd', 'c'], 'c': ['x', 'd', 'f', 'v'],
    'v': ['c', 'f', 'g', 'b'], 'b': ['v', 'g', 'h', 'n'],
    'n': ['b', 'h', 'j', 'm'], 'm': ['n', 'j', 'k'],
  };

  static const _skipWords = ['a', 'is', 'of', 'the', 'to', 'in', 'it', 'be', 'as', 'at', 'by', 'we'];

  static Map<int, PlannedError?> createPlan(
    String text,
    ErrorProfile profile,
    TypingMode mode,
  ) {
    final plan = <int, PlannedError?>{};
    if (profile.errorsPerLine == 0) return plan;

    final words = _tokenize(text);
    int lastErrorIndex = -5;  // Enforce min gap between errors

    for (final word in words) {
      // Skip short/common words
      if (_skipWords.contains(word.text.toLowerCase())) continue;
      if (word.text.length <= 2) continue;

      // Enforce error rate per line
      if (_shouldInjectError(word, profile)) {
        final charIndex = _chooseErrorPosition(word);

        // Enforce gap between errors
        if (charIndex - lastErrorIndex < 5) continue;

        // In code mode, check zone safety
        if (mode == TypingMode.code) {
          // Only inject in safe zones (checked by CodeAnalyzer)
          if (!CodeAnalyzer.isSafeZone(charIndex, text)) continue;
        }

        plan[charIndex] = PlannedError(
          type: _chooseErrorType(text[charIndex], profile),
          correction: profile.correctionStyle,
        );
        lastErrorIndex = charIndex;
      }
    }

    return plan;
  }

  static ErrorType _chooseErrorType(String char, ErrorProfile profile) {
    final allowed = profile.allowedErrorTypes;
    // Weight toward adjacent key (most common real typo)
    if (allowed.contains(ErrorType.adjacentKey) &&
        _adjacentKeys.containsKey(char.toLowerCase())) {
      return ErrorType.adjacentKey;
    }
    // Fallback to transposition
    if (allowed.contains(ErrorType.transposition)) return ErrorType.transposition;
    return allowed.first;
  }
}
```

---

### B3.4 Code Analyzer

```dart
// code_analyzer.dart

enum CodeZone { syntaxKeyword, syntaxOperator, syntaxStructure, variableName, stringContent, comment, importPath }

class CodeAnalyzer {

  static Map<int, CodeZone> analyzeZones(String code, ProgrammingLanguage lang) {
    // Returns a map of character index → zone type
    // Used by ErrorInjector to determine safe positions
    final zones = <int, CodeZone>{};
    // Parse line by line, classify each character
    final lines = code.split('\n');
    int offset = 0;

    for (final line in lines) {
      final lineZones = _analyzeLine(line.trim(), lang);
      for (int i = 0; i < line.length; i++) {
        zones[offset + i] = lineZones[i] ?? CodeZone.variableName;
      }
      offset += line.length + 1; // +1 for newline
    }
    return zones;
  }

  static bool isSafeZone(int charIndex, String code) {
    // Quick check without full analysis — for error injector
    // Errors only allowed in: variableName, stringContent, comment
    // Never in: syntaxKeyword, syntaxOperator, syntaxStructure, importPath
    final zones = analyzeZones(code, _detectLanguage(code));
    final zone = zones[charIndex];
    return zone == CodeZone.variableName ||
           zone == CodeZone.stringContent ||
           zone == CodeZone.comment;
  }

  static ProgrammingLanguage _detectLanguage(String code) {
    if (code.contains('def ') || code.contains('import ') && code.contains(':')) return ProgrammingLanguage.python;
    if (code.contains('function ') || code.contains('const ') || code.contains('=>')) return ProgrammingLanguage.javascript;
    if (code.contains('Widget') || code.contains('@override')) return ProgrammingLanguage.dart;
    if (code.contains('public class') || code.contains('System.out')) return ProgrammingLanguage.java;
    return ProgrammingLanguage.unknown;
  }
}
```

---

### B3.5 Cloud AI — Claude API Service (Optional)

```dart
// claude_api_service.dart

class ClaudeApiService {

  final String apiKey;
  static const _model = 'claude-sonnet-4-20250514';
  static const _endpoint = 'https://api.anthropic.com/v1/messages';

  // Parse natural language instructions → structured sections
  Future<List<Section>> parseInstructions(String naturalLanguageInput) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1000,
        'system': '''You are a typing session configurator. 
          Convert the user's natural language instructions into a structured JSON 
          array of sections. Each section has: name, content, speed (slow/medium/fast), 
          errorsPerLine (0-5), correctionStyle (immediate/word_end/sentence_end), 
          preAction, postAction. Return ONLY valid JSON, no explanation.''',
        'messages': [
          {'role': 'user', 'content': naturalLanguageInput}
        ],
      }),
    );

    final data = jsonDecode(response.body);
    final text = data['content'][0]['text'] as String;
    final json = jsonDecode(text) as List;
    return json.map((j) => Section.fromJson(j)).toList();
  }

  // Process OCR text received from Windows app
  Future<String> processOcrResult(String ocrText, String userIntent) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1000,
        'messages': [
          {
            'role': 'user',
            'content': 'Screen content:\n$ocrText\n\nUser intent: $userIntent\n\nPrepare the appropriate response to type.'
          }
        ],
      }),
    );

    final data = jsonDecode(response.body);
    return data['content'][0]['text'] as String;
  }
}
```

---

## B4. Section & Instruction System

### B4.1 Section Builder UI (Bottom Sheet)

```
┌──────────────────────────────────────┐
│  ╌╌╌ (drag handle)                  │
│                                      │
│  Section Name                        │
│  ┌────────────────────────────────┐  │
│  │ Essay Answer                   │  │
│  └────────────────────────────────┘  │
│                                      │
│  Target              Mode            │
│  [ Active Window ▼ ] [ Text ▼ ]     │
│                                      │
│  Speed                               │
│  Slow ───────●──────────── Fast      │
│              Medium · 65 WPM         │
│                                      │
│  Errors per line      Correction     │
│  [ 0 ][ 1 ][●2][ 3 ] [Word end ▼]  │
│                                      │
│  Before typing       After typing    │
│  [Wait 3s ▼]         [Press Tab ▼]  │
│                                      │
│  [✓] Wait for my tap to start       │
│                                      │
│  Content                             │
│  ┌────────────────────────────────┐  │
│  │ My name is John and I study   │  │
│  │ at the University of Delhi... │  │
│  └────────────────────────────────┘  │
│                                      │
│  [ CANCEL ]            [ SAVE ✓ ]   │
└──────────────────────────────────────┘
```

### B4.2 AI Instruction Mode

User types casual instruction → AI parses → sections created automatically:

```dart
class InstructionParser {
  final ClaudeApiService ai;

  Future<List<Section>> parse(String instruction) async {
    // First try local rule-based parse (no API needed for simple cases)
    final local = _tryLocalParse(instruction);
    if (local != null) return local;

    // Fall back to Claude API for complex instructions
    return await ai.parseInstructions(instruction);
  }

  List<Section>? _tryLocalParse(String instruction) {
    // Simple patterns: "type X slowly", "fill name field", etc.
    // Returns null if too complex for local parsing
  }
}
```

---

## B5. Code Mode Intelligence

### B5.1 Code Mode Typing Rhythm

```dart
class CodeModeHumanizer {

  static Map<int, int> analyzeCodeRhythm(String code, SpeedProfile speed, ProgrammingLanguage lang) {
    final delays = <int, int>{};
    final zones = CodeAnalyzer.analyzeZones(code, lang);
    final lines = code.split('\n');
    int offset = 0;

    for (int lineIdx = 0; lineIdx < lines.length; lineIdx++) {
      final line = lines[lineIdx];

      // Pause before function definitions
      if (_isFunctionDef(line, lang)) {
        delays[offset] = (delays[offset] ?? speed.baseDelayMs) + _randomInRange(1200, 2500);
      }
      // Pause before complex logic
      else if (_isComplexLogic(line, lang)) {
        delays[offset] = (delays[offset] ?? speed.baseDelayMs) + _randomInRange(400, 900);
      }

      for (int i = 0; i < line.length; i++) {
        final idx = offset + i;
        final zone = zones[idx];
        int delay = speed.baseDelayMs;

        switch (zone) {
          case CodeZone.syntaxKeyword:
            delay = (delay * 0.6).round();  // Keywords typed fast
          case CodeZone.comment:
            delay = (delay * 1.4).round();  // Comments typed slow (composing)
          case CodeZone.stringContent:
            delay = (delay * 1.1).round();  // Strings slightly slower
          default:
            break;
        }

        // Indent characters (tabs/spaces) typed fast
        if (i < line.length - line.trimLeft().length) {
          delay = (delay * 0.4).round();
        }

        delays[idx] = _applyVariance(delay);
      }

      // Pause at end of line (thinking before next line)
      delays[offset + line.length] = _randomInRange(200, 600);
      offset += line.length + 1;
    }

    return delays;
  }
}
```

---

## B6. Connection Management

### B6.1 WiFi Service (WebSocket Client)

```dart
// wifi_service.dart

class WiFiService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<WsMessage>.broadcast();

  Stream<WsMessage> get messages => _messageController.stream;

  Future<void> connect(String ip, int port, String pairingToken) async {
    _channel = WebSocketChannel.connect(Uri.parse('ws://$ip:$port'));

    // Send handshake immediately
    send(WsMessage(
      type: MessageType.handshake,
      sender: DeviceInfo.android(),
      payload: {'pairing_token': pairingToken},
    ));

    // Send capabilities
    send(WsMessage(
      type: MessageType.capabilityAdvertisement,
      sender: DeviceInfo.android(),
      payload: Capabilities.android().toJson(),
    ));

    // Listen for incoming
    _channel!.stream.listen(
      (data) => _messageController.add(WsMessage.fromJson(jsonDecode(data))),
      onError: _handleError,
      onDone: _handleDisconnect,
    );
  }

  void send(WsMessage message) {
    _channel?.sink.add(jsonEncode(message.toJson()));
  }

  Future<void> sendCommandQueue(List<TypeCommand> queue) async {
    for (final cmd in queue) {
      // Check for pause signal before each command
      if (_isPaused) {
        await _waitForResume();
      }
      send(WsMessage(
        type: MessageType.cmd,
        sender: DeviceInfo.android(),
        target: _bridgeDeviceId,
        payload: cmd.toJson(),
      ));
      // Small buffer to avoid flooding
      await Future.delayed(const Duration(milliseconds: 2));
    }
  }

  bool _isPaused = false;
  void pause() => _isPaused = true;
  void resume() => _isPaused = false;
}
```

### B6.2 mDNS Discovery

```dart
// mdns_discovery.dart

class MdnsDiscovery {

  static Future<List<DiscoveredDevice>> scan({Duration timeout = const Duration(seconds: 5)}) async {
    final devices = <DiscoveredDevice>[];
    final client = MDnsClient();
    await client.start();

    await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer('_humantype._tcp'),
    ).timeout(timeout, onTimeout: (_) {})) {

      await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName),
      )) {
        await for (final IPAddressResourceRecord ip in client.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(srv.target),
        )) {
          devices.add(DiscoveredDevice(
            name: ptr.domainName,
            ip: ip.address.address,
            port: srv.port,
          ));
        }
      }
    }

    client.stop();
    return devices;
  }
}
```

### B6.3 Bluetooth Service

```dart
// bluetooth_service.dart

class BluetoothService {

  Future<List<BluetoothDevice>> scanForHumanTypeDevices() async {
    final results = await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    // Filter for devices running HumanType Bridge
    return results
      .map((r) => r.device)
      .where((d) => d.platformName.contains('HumanType'))
      .toList();
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 10));
    // Discover services, find HumanType characteristic
    final services = await device.discoverServices();
    // ... setup read/write streams
  }
}
```

### B6.4 Connection Quality Monitor

```dart
enum ConnectionQuality { excellent, good, fair, poor, bluetooth, disconnected }

class ConnectionMonitor {
  Timer? _pingTimer;
  final _qualityController = StreamController<ConnectionQuality>.broadcast();

  Stream<ConnectionQuality> get quality => _qualityController.stream;

  void startMonitoring(WiFiService wifi) {
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final start = DateTime.now();
      await wifi.ping();
      final latency = DateTime.now().difference(start).inMilliseconds;
      _qualityController.add(_classify(latency));
    });
  }

  ConnectionQuality _classify(int latencyMs) {
    if (latencyMs < 30) return ConnectionQuality.excellent;
    if (latencyMs < 80) return ConnectionQuality.good;
    if (latencyMs < 150) return ConnectionQuality.fair;
    return ConnectionQuality.poor;
  }
}
```

---

## B7. UI/UX Design System — Android

**See Part F for complete global design tokens. Use them exactly.**

### B7.1 Screen Architecture

```
Splash Screen (1.5s, animated logo)
  └── Onboarding (3 slides, first launch only)
        └── Home Screen
              ├── Connect Screen
              │     └── Device List / Manual IP
              ├── Text Mode Screen
              │     ├── Section List (drag to reorder)
              │     ├── Section Builder (bottom sheet)
              │     ├── AI Instruction Input
              │     └── Execution Screen
              ├── Code Mode Screen
              │     ├── Code Input + Language Selector
              │     └── Execution Screen
              ├── Templates Screen
              │     └── Template Detail / Editor
              ├── History Screen
              └── Settings Screen
                    ├── Typing Defaults
                    ├── Connection
                    ├── AI (Claude API key)
                    ├── Privacy
                    └── About
```

### B7.2 Home Screen Layout

```
Status bar
┌──────────────────────────────────────┐
│                              ⚙️      │  ← Settings icon top-right
│  HumanType                           │
│  Good morning                        │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  ●  My Dell Laptop     24ms   │  │  ← Connection chip
│  │     WiFi · Excellent          │  │     Pulsing green dot
│  └────────────────────────────────┘  │
│                                      │
│  ┌──────────────┐ ┌──────────────┐   │
│  │              │ │              │   │  ← Mode cards
│  │  📝           │ │  💻           │   │     Full-width tap targets
│  │  Text Mode   │ │  Code Mode   │   │
│  │              │ │              │   │
│  └──────────────┘ └──────────────┘   │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  📋 Templates        3 saved │    │  ← Quick access cards
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  🕐 Last Session      2h ago │    │
│  │     Form Fill · 847 chars    │    │
│  └──────────────────────────────┘    │
│                                      │
└──────────────────────────────────────┘
```

### B7.3 Execution Screen (Critical — Must Feel Alive)

```
┌──────────────────────────────────────┐
│  ✕                                   │  ← X to confirm-stop
│                                      │
│         TYPING IN PROGRESS           │  ← Title, subtle pulse animation
│                                      │
│  ●────────○────────○────────○        │  ← Section progress dots
│  1        2        3        4        │     Current = filled, animated
│  Section 2 of 4                      │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ "Hello my name is John and I  │  │  ← Live text preview
│  │  study at the University of D" │  │     Monospace font
│  │                         █      │  │     Blinking cursor at position
│  └────────────────────────────────┘  │
│                                      │
│  ████████████████░░░░░░  67%         │  ← Animated fill progress bar
│                                      │
│  847 / 1,263 chars                   │
│  ~45s remaining  ·  68 WPM           │
│                                      │
│  ┌────────────────────────────────┐  │
│  │          ⏸  PAUSE             │  │  ← Large, prominent pause button
│  └────────────────────────────────┘  │
│                                      │
│  ■ STOP SESSION                      │  ← Smaller stop, below pause
└──────────────────────────────────────┘
```

### B7.4 Key UX Rules for Android

1. **Execution screen must be distraction-free** — user's attention on laptop, not phone
2. **PAUSE button must be reachable with one thumb** — always bottom 40% of screen
3. **STOP requires confirmation** — one accidental tap shouldn't kill a session
4. **Section progress dots** must visually communicate "3 more to go"
5. **Live text preview** shows exactly what's being typed right now (monospace)
6. **Haptic feedback** on START, PAUSE, STOP, section complete
7. **Screen-on lock** — keep screen awake during active execution

---

## B8. State Management — Riverpod

```dart
// Core providers
final connectionProvider = AsyncNotifierProvider<ConnectionNotifier, ConnectionState>(
  ConnectionNotifier.new
);

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new
);

final executionProvider = NotifierProvider<ExecutionNotifier, ExecutionState>(
  ExecutionNotifier.new
);

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new
);

// ConnectionState
class ConnectionState {
  final bool isConnected;
  final ConnectedDevice? device;
  final ConnectionQuality quality;
  final ConnectionMethod method;  // wifi, bluetooth
}

// SessionState
class SessionState {
  final SessionStatus status;     // idle, planning, ready, executing, paused, completed, aborted
  final List<Section> sections;
  final int currentSectionIndex;
  final int charsCompleted;
  final int charsTotal;
  final int estimatedSecondsRemaining;
  final double currentWpm;
}

// ExecutionState
class ExecutionState {
  final List<TypeCommand> queue;
  final int queuePosition;
  final String? currentChar;
  final bool isPaused;
}
```

---

## B9. Local Storage — Hive

```dart
// All Hive boxes
@HiveType(typeId: 0) class DeviceModel extends HiveObject { ... }
@HiveType(typeId: 1) class SessionModel extends HiveObject { ... }
@HiveType(typeId: 2) class TemplateModel extends HiveObject { ... }
@HiveType(typeId: 3) class FieldMapModel extends HiveObject { ... }
@HiveType(typeId: 4) class AppSettings extends HiveObject { ... }
@HiveType(typeId: 5) class ErrorProfile extends HiveObject { ... }

// Initialization
Future<void> initHive() async {
  await Hive.initFlutter();
  // Register adapters
  Hive.registerAdapter(DeviceModelAdapter());
  // ...
  // Open encrypted boxes
  final encryptionKey = await _getOrCreateEncryptionKey();
  await Hive.openBox<DeviceModel>('devices',
    encryptionCipher: HiveAesCipher(encryptionKey));
  // ... open all boxes
}

Future<Uint8List> _getOrCreateEncryptionKey() async {
  const storage = FlutterSecureStorage();
  var key = await storage.read(key: 'hive_encryption_key');
  if (key == null) {
    final newKey = Hive.generateSecureKey();
    await storage.write(key: 'hive_encryption_key', value: base64Encode(newKey));
    return Uint8List.fromList(newKey);
  }
  return base64Decode(key);
}
```

---

# PART E — COMMUNICATION PROTOCOL (Shared Contract with Agent 2)

> ⚠️ This protocol is the contract between your Android app and Agent 2's Bridge/Windows app.
> Do NOT deviate from these message formats. Agent 2 is coding to the same spec.

---

## E1. Base Message Format

```json
{
  "version": "1.0",
  "type": "MESSAGE_TYPE",
  "id": "uuid-v4",
  "timestamp": 1700000000000,
  "sender": {
    "device_id": "uuid",
    "device_type": "android | windows | bridge",
    "current_role": "controller | executor | both | passive"
  },
  "target": {
    "device_id": "uuid | broadcast"
  },
  "payload": { }
}
```

## E2. All Message Types You Send/Receive

```dart
enum MessageType {
  // Connection
  handshake,                  // First message on connect
  handshakeAck,               // Response to handshake
  capabilityAdvertisement,    // Device capabilities
  heartbeat,                  // Keep-alive ping
  heartbeatAck,               // Keep-alive pong
  disconnect,                 // Graceful disconnect

  // Execution (you SEND, bridge RECEIVES)
  cmd,                        // Single character/key command
  sessionControl,             // Start/pause/resume/abort

  // Progress (bridge SENDS, you RECEIVE)
  progress,                   // Typing progress update
  sectionComplete,            // One section finished

  // Sync (windows app SENDS, you RECEIVE, and vice versa)
  settingsSync,               // Settings changed on one side
  ocrResult,                  // Screen capture text from Windows

  // Role management
  roleChange,                 // Request role change
  deviceRegistry,             // Full device list broadcast
}
```

## E3. Key Message Payloads

```json
// CMD — you send this for every character
{
  "type": "cmd",
  "payload": {
    "action": "CHAR | SPECIAL_KEY | HOTKEY | PAUSE | CLICK",
    "char": "h",
    "key": "enter",
    "keys": ["ctrl", "s"],
    "delay_pre_ms": 85,
    "x": 452,
    "y": 312
  }
}

// SESSION_CONTROL
{
  "type": "sessionControl",
  "payload": {
    "action": "START | PAUSE | RESUME | ABORT | COMPLETE"
  }
}

// PROGRESS (you receive from bridge)
{
  "type": "progress",
  "payload": {
    "chars_sent": 847,
    "chars_total": 1263,
    "section_index": 1,
    "sections_total": 4,
    "current_wpm": 68,
    "eta_seconds": 45
  }
}

// OCR_RESULT (you receive from Windows app)
{
  "type": "ocrResult",
  "payload": {
    "text": "Extracted text from screen...",
    "app_name": "Google Chrome",
    "window_title": "Question 3 of 10"
  }
}

// SETTINGS_SYNC (bidirectional)
{
  "type": "settingsSync",
  "payload": {
    "changed_key": "typing.speed_profile",
    "new_value": "fast",
    "source_device": "android"
  }
}
```

---

# PART F — UI/UX DESIGN SYSTEM

## F1. Design Philosophy

Four pillars:
1. **Dark Precision** — Dark-first. Interface disappears, content is king.
2. **Information Density Done Right** — No wasted space, but not cramped.
3. **Motion With Purpose** — Every animation communicates state.
4. **Control Clarity** — User always knows: what's happening, what can I do, how do I stop.

---

## F2. Color System (Use These Exact Values)

```dart
// theme.dart — Android

class HumanTypeColors {
  // Backgrounds
  static const bgPrimary    = Color(0xFF0A0A0F);
  static const bgSecondary  = Color(0xFF111118);
  static const bgElevated   = Color(0xFF1A1A24);
  static const bgOverlay    = Color(0xFF22222E);

  // Borders
  static const borderSubtle  = Color(0xFF2A2A3A);
  static const borderDefault = Color(0xFF3A3A4E);
  static const borderStrong  = Color(0xFF5A5A7A);

  // Brand
  static const accentPrimary   = Color(0xFF6C63FF);  // Electric violet
  static const accentSecondary = Color(0xFF4ECDC4);  // Teal
  static const accentDanger    = Color(0xFFFF6B6B);  // Coral/red

  // Semantic
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);
  static const error   = Color(0xFFE74C3C);
  static const info    = Color(0xFF3498DB);

  // Connection quality
  static const connExcellent    = Color(0xFF2ECC71);
  static const connGood         = Color(0xFF27AE60);
  static const connFair         = Color(0xFFF39C12);
  static const connPoor         = Color(0xFFE67E22);
  static const connBluetooth    = Color(0xFF3498DB);
  static const connDisconnected = Color(0xFFE74C3C);
}
```

## F3. Typography

```dart
// Use Google Fonts: Inter + JetBrains Mono

class HumanTypeText {
  static TextStyle display    = GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700);
  static TextStyle heading1   = GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600);
  static TextStyle heading2   = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle bodyLarge  = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle body       = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle bodySmall  = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400);
  static TextStyle caption    = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500);
  static TextStyle monoLarge  = GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle mono       = GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w400);
}
```

## F4. Spacing Grid

**Base unit: 4px. All spacing is multiples of 4.**

```dart
class HumanTypeSpacing {
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 12.0;
  static const lg  = 16.0;
  static const xl  = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}
```

## F5. Animation Timings

```dart
class HumanTypeAnimation {
  static const quick     = Duration(milliseconds: 150);  // Toggles, button presses
  static const standard  = Duration(milliseconds: 250);  // Panel transitions
  static const deliberate= Duration(milliseconds: 400);  // Screen transitions
  static const slow      = Duration(milliseconds: 600);  // Onboarding

  static const easeOut   = Curves.easeOut;
  static const easeInOut = Curves.easeInOut;
}
```

## F6. Premium Feel Rules

1. Never show raw error strings — always a friendly message + action
2. Any action >100ms shows loading indicator
3. **Spacing grid: 4px base, always multiples of 4**
4. Empty states have illustration + CTA, never blank
5. Every tap: ripple + scale animation (96% press scale)
6. Haptic feedback: START, PAUSE, STOP, section complete
7. Destructive actions (stop, delete) require confirmation
8. Settings organized by user mental model, not technical categories
9. Screen stays on during active execution (WakeLock)
10. Typography hierarchy strictly enforced — never two competing weights

---

# PART G — ENGINEERING STANDARDS

## G1. Performance Targets (Android)

| Metric | Target |
|--------|--------|
| App startup to home screen | < 2s |
| Connect to known device | < 2s |
| Command latency (tap → laptop keystroke) | < 50ms |
| Execution planner (1000 chars) | < 200ms |
| Memory usage | < 150MB |
| Frame rate during execution | 60fps |

## G2. Error Handling Rules

- Every async operation in try-catch
- User sees friendly message, never raw exception
- All errors logged locally only
- Connection errors during session → auto-retry 5x → then notify user
- `handleUnknownMessage` must never crash — log + ignore unknown types

## G3. Security

- Hive encrypted with AES-256
- Key in Android Keystore via flutter_secure_storage
- Pairing token: SHA-256, device-pair-specific
- No data to external servers unless Claude AI explicitly enabled
- Rate limiting on command sending: max 2000 cmd/min

---

# PART H — DEVELOPMENT PHASES (Android Side)

### Phase 1 (Weeks 1–3): Foundation
- [ ] Setup project structure + shared package
- [ ] Define ALL models and message types in shared package
- [ ] Basic WebSocket connection to bridge
- [ ] Handshake + capability exchange
- [ ] Simple text → send as commands (no humanization yet)
- **Milestone:** "Hello World" typed on laptop from phone

### Phase 2 (Weeks 4–7): Human Engine
- [ ] Humanizer (rhythm + variance)
- [ ] Error injector (all types + corrections)
- [ ] Execution planner (full queue builder)
- [ ] Speed profiles
- [ ] Pause / Resume / Stop
- **Milestone:** 500-word essay typed, feels fully human

### Phase 3 (Weeks 8–10): Section System
- [ ] Section model + builder UI
- [ ] Pre/post actions
- [ ] Manual section start (tap to proceed)
- [ ] Progress tracking
- **Milestone:** 4-field form filled from phone

### Phase 4 (Weeks 11–12): Code Mode
- [ ] Language detector
- [ ] Code zone mapper
- [ ] Code rhythm engine
- [ ] Code mode UI
- **Milestone:** 50-line Python function typed realistically

### Phase 5 (Weeks 13–14): Connection
- [ ] mDNS auto-discovery
- [ ] Bluetooth fallback
- [ ] Auto-connect on launch
- [ ] Reconnect during session
- **Milestone:** Opens app → connected in <2s

### Phase 6 (Weeks 15–16): Windows Sync
- [ ] Receive OCR results from Windows app
- [ ] Settings sync with Windows app
- [ ] Stealth mode signal handling
- **Milestone:** Capture screen on Windows, AI processes on Android

### Phase 7 (Weeks 17–18): AI Layer
- [ ] Claude API integration
- [ ] Natural language instruction parser
- [ ] OCR result processing
- **Milestone:** Type instructions in plain English → sections created

### Phase 8 (Weeks 19–20): Polish
- [ ] Full design system on all screens
- [ ] Onboarding flow
- [ ] Empty/error/loading states everywhere
- [ ] Templates + history
- [ ] WakeLock during execution
- [ ] Haptic feedback
- **Milestone:** Beta-ready APK

---

*AGENT 1 — Android Build Specification*  
*HumanType v4.0 | Give this file to your Android Flutter AI*  
*Agent 2 is building the Windows App + Python Bridge in parallel*