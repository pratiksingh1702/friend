# HumanType — AGENT 2: Windows App + Python Bridge
### *Build Specification for Flutter Windows Desktop App + Python Bridge*

**Version:** 4.0  
**Your Role:** Build the **Flutter Windows Desktop App** + **Python Bridge**  
**Parallel Agent:** Agent 1 is simultaneously building the Android APK  

---

> ⚠️ **READ THIS FIRST — COORDINATION RULES**
>
> You are Agent 2. Agent 1 is building the Android App.
>
> **Shared contract between both agents:**
> - All WebSocket messages use the protocol defined in PART E (included below)
> - Data models are defined in `packages/humantype_shared/` — Agent 1 defines them, **you import them**
> - WebSocket **server** runs on laptop port **8765** — YOU own and run this server (bridge)
> - mDNS service: `_humantype._tcp.local` — YOU broadcast this (bridge broadcasts, Android discovers)
> - Pairing token: SHA-256 — Agent 1 generates it, **you validate it**
> - Every message includes `sender.device_id`, `sender.current_role`, `target.device_id`
> - On connect, both sides send `CAPABILITY_ADVERTISEMENT` message immediately
>
> **You own:** `apps/humantype_windows/` + `bridge/humantype_bridge/`  
> **Agent 1 owns:** `apps/humantype_android/` + `packages/humantype_shared/`  
> **Your dependency:** Import `humantype_shared` package for all models + protocol types

---

## Your Deliverable

### 1. Python Bridge (`bridge/humantype_bridge/`)
A small, silent `.exe` that:
- Runs in background at startup (system tray, no window)
- Opens WebSocket server on port 8765
- Validates pairing token from Android
- Receives character commands and types them via `pyautogui`
- Broadcasts itself via mDNS so Android can find it
- Packaged as single `.exe` via PyInstaller

### 2. Flutter Windows Desktop App (`apps/humantype_windows/`)
A premium desktop application that:
- Shows full settings panel + live session dashboard
- Has a **floating overlay window** (invisible to screen recorders via `WDA_EXCLUDEFROMCAPTURE`)
- Captures screen via OCR, sends text to Android app
- Shows live field calibration using screen mirror
- Syncs all settings bidirectionally with Android
- Has Stealth/Demo mode that hides everything

---

## Project Structure (Your Part)

```
humantype/
│
├── apps/
│   └── humantype_windows/              ← YOU OWN THIS
│       ├── lib/
│       │   ├── main.dart
│       │   ├── core/
│       │   │   ├── router.dart
│       │   │   ├── theme.dart          ← Full Windows design system
│       │   │   └── providers.dart
│       │   └── features/
│       │       ├── dashboard/
│       │       │   ├── screens/dashboard_screen.dart
│       │       │   └── widgets/session_status_card.dart
│       │       ├── overlay/
│       │       │   ├── overlay_window.dart      ← Separate Flutter window
│       │       │   ├── overlay_ui.dart          ← Overlay widget tree
│       │       │   └── wda_manager.dart         ← Win32 WDA_EXCLUDEFROMCAPTURE
│       │       ├── ocr/
│       │       │   ├── services/ocr_service.dart
│       │       │   └── services/screenshot_service.dart
│       │       ├── calibration/
│       │       │   ├── screens/calibration_screen.dart
│       │       │   └── services/field_mapper.dart
│       │       ├── stealth/
│       │       │   └── services/stealth_manager.dart
│       │       ├── settings/
│       │       │   ├── screens/settings_screen.dart
│       │       │   └── screens/ [sub-settings screens]
│       │       ├── sync/
│       │       │   └── services/android_sync_service.dart
│       │       └── tray/
│       │           └── tray_manager_service.dart
│       ├── windows/                    ← Flutter Windows native files
│       │   └── runner/
│       └── pubspec.yaml
│
└── bridge/
    └── humantype_bridge/               ← YOU OWN THIS
        ├── main.py
        ├── server/
        │   ├── websocket_server.py
        │   └── bluetooth_server.py
        ├── executor/
        │   ├── keyboard_executor.py
        │   ├── mouse_executor.py       ← Future
        │   └── command_parser.py
        ├── discovery/
        │   └── mdns_broadcast.py
        ├── security/
        │   └── token_validator.py
        ├── tray/
        │   └── tray_icon.py
        ├── window_monitor/
        │   └── focus_detector.py      ← Detect active window/URL
        ├── requirements.txt
        └── humantype_bridge.spec      ← PyInstaller config
```

---

## pubspec.yaml — Windows App

```yaml
name: humantype_windows
description: HumanType — Windows Desktop App + Overlay

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.16.0'

dependencies:
  flutter:
    sdk: flutter

  # Shared package (Agent 1 defines this)
  humantype_shared:
    path: ../../packages/humantype_shared

  # State management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Navigation
  go_router: ^13.0.0

  # Networking
  web_socket_channel: ^2.4.0

  # Windows-specific
  win32: ^5.5.0                    # Windows API (WDA, HWND, etc.)
  ffi: ^2.1.0                      # FFI for win32 calls
  screen_retriever: ^0.1.9         # Screenshots
  window_manager: ^0.3.8           # Window control (overlay positioning)
  tray_manager: ^0.2.2             # System tray icon

  # OCR
  flutter_tesseract_ocr: ^0.4.11   # Tesseract fallback
  # Windows native OCR used via method channel (see ocr_service.dart)

  # Local database
  hive_flutter: ^1.1.0
  hive: ^2.2.3
  flutter_secure_storage: ^9.0.0

  # UI
  google_fonts: ^6.1.0
  fluent_ui: ^4.8.6                # Fluent Design components

  # Utilities
  uuid: ^4.3.3
  crypto: ^3.0.3
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
  flutter_lints: ^3.0.0
```

---

## requirements.txt — Python Bridge

```
websockets==12.0
pyautogui==0.9.54
pynput==1.7.6
zeroconf==0.131.0
PyBluez==0.23          # Bluetooth support
pystray==0.19.5        # System tray
Pillow==10.2.0         # Required by pystray + pyautogui screenshots
psutil==5.9.8          # Process/system info
pywin32==306           # Windows API (alternative to win32 for Python)
pyinstaller==6.4.0     # Packaging
```

---

# PART A — PRODUCT OVERVIEW (Shared Context)

---

## A1. Vision & Mission

HumanType turns any laptop into a remote typing machine, controlled by a phone. The Windows app is the **command center on the laptop screen** — visible to you, invisible to recordings. The Python bridge is the **invisible executor** — silently types everything it's told.

**Product Tagline:** *"Your words. Your control. Any device. Any direction."*

---

## A2. Core Philosophy

```
PHONE  =  BRAIN          LAPTOP  =  HANDS
All intelligence         Dumb executor (bridge)
All decisions            Types what it's told
User carries this        Windows app = your HUD on screen
```

**Your two components:**
- **Python Bridge** → dumb slave. Receives commands, types them. That's it.
- **Windows App** → smart HUD. Shows status, settings, overlay, OCR. Does NOT type.

---

## A3. System Topology (Your Part Highlighted)

```
Android App (Agent 1)
       │
       │  WiFi WebSocket  /  Bluetooth
       │
       ├──────────────────────────────────► PYTHON BRIDGE ★
       │                                    (port 8765)
       │                                    Validates token
       │                                    Receives CMD messages
       │                                    pyautogui → types
       │
       └──────────────────────────────────► WINDOWS FLUTTER APP ★
                                            (direct WiFi connection)
                                            Settings sync
                                            OCR → send to Android
                                            Overlay HUD
                                            Calibration

         ← localhost WebSocket →
         Bridge ◄──────────────► Windows App
         (same machine, ultra-low latency)
```

---

# PART D — PYTHON BRIDGE (Build This First)

---

## D1. Architecture Overview

The bridge is **intentionally minimal**. Keep it simple. Every line of complexity is a bug waiting to happen.

```python
# main.py — startup sequence

import asyncio
from server.websocket_server import WebSocketServer
from server.bluetooth_server import BluetoothServer
from discovery.mdns_broadcast import MdnsBroadcast
from tray.tray_icon import TrayIcon
from security.token_validator import TokenValidator

async def main():
    # 1. Load stored pairing tokens
    validator = TokenValidator()
    validator.load()

    # 2. Start mDNS broadcast (so Android can find us)
    mdns = MdnsBroadcast()
    mdns.start()

    # 3. Start WebSocket server
    ws_server = WebSocketServer(validator=validator)

    # 4. Start Bluetooth server (if BT available)
    bt_server = BluetoothServer(validator=validator)

    # 5. Show system tray
    tray = TrayIcon()
    tray.show()

    # 6. Run all servers
    await asyncio.gather(
        ws_server.start(host='0.0.0.0', port=8765),
        bt_server.start(),
    )

if __name__ == '__main__':
    asyncio.run(main())
```

---

## D2. WebSocket Server

```python
# server/websocket_server.py

import asyncio
import json
import websockets
from executor.keyboard_executor import KeyboardExecutor
from executor.command_parser import CommandParser
from security.token_validator import TokenValidator

class WebSocketServer:

    def __init__(self, validator: TokenValidator):
        self.validator = validator
        self.executor = KeyboardExecutor()
        self.parser = CommandParser()
        self.connected_clients = {}   # device_id → websocket
        self._paused = False
        self._abort = False

    async def start(self, host: str, port: int):
        print(f"[Bridge] WebSocket server starting on {host}:{port}")
        async with websockets.serve(self._handle_client, host, port):
            await asyncio.Future()  # run forever

    async def _handle_client(self, websocket, path):
        device_id = None
        try:
            # First message MUST be handshake
            raw = await asyncio.wait_for(websocket.recv(), timeout=10.0)
            message = json.loads(raw)

            if message.get('type') != 'handshake':
                await websocket.close(1008, 'Handshake required first')
                return

            # Validate pairing token
            token = message.get('payload', {}).get('pairing_token', '')
            sender = message.get('sender', {})
            device_id = sender.get('device_id')

            if not self.validator.validate(device_id, token):
                # New device — store token (first-time pairing)
                if self.validator.is_first_connection():
                    self.validator.store(device_id, token)
                    print(f"[Bridge] New device paired: {device_id}")
                else:
                    await websocket.close(1008, 'Authentication failed')
                    return

            # Send handshake ack
            await websocket.send(json.dumps({
                'type': 'handshake_ack',
                'payload': {'status': 'ok', 'bridge_version': '1.0.0'}
            }))

            # Send capabilities
            await websocket.send(json.dumps({
                'type': 'capability_advertisement',
                'payload': {
                    'can_be_controller': False,
                    'can_be_executor': True,
                    'has_keyboard_control': True,
                    'has_mouse_control': False,
                    'platform': 'bridge',
                    'protocol_version': '1.0'
                }
            }))

            self.connected_clients[device_id] = websocket
            print(f"[Bridge] Connected: {device_id}")

            # Main command loop
            async for raw_message in websocket:
                await self._handle_message(json.loads(raw_message), websocket)

        except websockets.exceptions.ConnectionClosed:
            print(f"[Bridge] Disconnected: {device_id}")
        except Exception as e:
            print(f"[Bridge] Error: {e}")
        finally:
            if device_id:
                self.connected_clients.pop(device_id, None)

    async def _handle_message(self, message: dict, websocket):
        msg_type = message.get('type')

        if msg_type == 'cmd':
            if not self._paused:
                command = self.parser.parse(message.get('payload', {}))
                await self.executor.execute(command)
                # Send ACK
                await websocket.send(json.dumps({
                    'type': 'cmd_ack',
                    'id': message.get('id')
                }))

        elif msg_type == 'session_control':
            action = message.get('payload', {}).get('action')
            if action == 'PAUSE':
                self._paused = True
                print('[Bridge] Paused')
            elif action == 'RESUME':
                self._paused = False
                print('[Bridge] Resumed')
            elif action == 'ABORT':
                self._paused = False
                self._abort = True
                print('[Bridge] Aborted')

        elif msg_type == 'heartbeat':
            await websocket.send(json.dumps({'type': 'heartbeat_ack'}))

        else:
            # Unknown message — log and ignore, never crash
            print(f"[Bridge] Unknown message type: {msg_type}")
            await websocket.send(json.dumps({
                'type': 'unsupported',
                'original_type': msg_type
            }))
```

---

## D3. Command Parser

```python
# executor/command_parser.py

from dataclasses import dataclass
from enum import Enum

class ActionType(Enum):
    CHAR = 'CHAR'
    SPECIAL_KEY = 'SPECIAL_KEY'
    HOTKEY = 'HOTKEY'
    PAUSE = 'PAUSE'
    CLICK = 'CLICK'

@dataclass
class ParsedCommand:
    action: ActionType
    char: str = None
    key: str = None
    keys: list = None
    delay_ms: int = 0
    x: int = None
    y: int = None

class CommandParser:

    def parse(self, payload: dict) -> ParsedCommand:
        action_str = payload.get('action', 'CHAR')
        action = ActionType(action_str)

        return ParsedCommand(
            action=action,
            char=payload.get('char'),
            key=payload.get('key'),
            keys=payload.get('keys', []),
            delay_ms=payload.get('delay_pre_ms', 0),
            x=payload.get('x'),
            y=payload.get('y'),
        )
```

---

## D4. Keyboard Executor

```python
# executor/keyboard_executor.py

import asyncio
import pyautogui

# Critical settings
pyautogui.FAILSAFE = False  # Disable mouse-corner emergency stop
pyautogui.PAUSE = 0         # We control ALL delays ourselves

class KeyboardExecutor:

    async def execute(self, command: 'ParsedCommand'):
        from executor.command_parser import ActionType

        # Apply the pre-command delay (this is the human timing)
        if command.delay_ms > 0:
            await asyncio.sleep(command.delay_ms / 1000.0)

        if command.action == ActionType.CHAR:
            if command.char:
                # Use typewrite for regular chars, press for special
                pyautogui.write(command.char, interval=0)

        elif command.action == ActionType.SPECIAL_KEY:
            key_map = {
                'enter': 'enter',
                'tab': 'tab',
                'backspace': 'backspace',
                'delete': 'delete',
                'escape': 'escape',
                'space': 'space',
                'up': 'up',
                'down': 'down',
                'left': 'left',
                'right': 'right',
                'home': 'home',
                'end': 'end',
                'pageup': 'pageup',
                'pagedown': 'pagedown',
            }
            key = key_map.get(command.key, command.key)
            pyautogui.press(key)

        elif command.action == ActionType.HOTKEY:
            if command.keys:
                pyautogui.hotkey(*command.keys)

        elif command.action == ActionType.CLICK:
            if command.x is not None and command.y is not None:
                pyautogui.click(command.x, command.y)

        elif command.action == ActionType.PAUSE:
            # Extra pause (beyond delay_ms) — for section breaks
            await asyncio.sleep(command.delay_ms / 1000.0)
```

---

## D5. mDNS Broadcast

```python
# discovery/mdns_broadcast.py

import socket
import platform
from zeroconf import ServiceInfo, Zeroconf

class MdnsBroadcast:

    def __init__(self, port: int = 8765):
        self.port = port
        self.zeroconf = None
        self.info = None

    def start(self):
        local_ip = self._get_local_ip()

        self.info = ServiceInfo(
            "_humantype._tcp.local.",
            f"HumanTypeBridge._humantype._tcp.local.",
            addresses=[socket.inet_aton(local_ip)],
            port=self.port,
            properties={
                b'device': socket.gethostname().encode(),
                b'os': platform.system().encode(),
                b'version': b'1.0.0',
                b'type': b'bridge',
            }
        )
        self.zeroconf = Zeroconf()
        self.zeroconf.register_service(self.info)
        print(f"[Bridge] mDNS broadcasting on {local_ip}:{self.port}")

    def stop(self):
        if self.zeroconf and self.info:
            self.zeroconf.unregister_service(self.info)
            self.zeroconf.close()

    def _get_local_ip(self) -> str:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            s.connect(('8.8.8.8', 80))
            return s.getsockname()[0]
        finally:
            s.close()
```

---

## D6. Security — Token Validator

```python
# security/token_validator.py

import hmac
import hashlib
import json
import os

class TokenValidator:

    TOKEN_FILE = 'paired_devices.json'

    def __init__(self):
        self.paired_devices = {}  # device_id → token_hash

    def load(self):
        if os.path.exists(self.TOKEN_FILE):
            with open(self.TOKEN_FILE, 'r') as f:
                self.paired_devices = json.load(f)

    def save(self):
        with open(self.TOKEN_FILE, 'w') as f:
            json.dump(self.paired_devices, f)

    def store(self, device_id: str, token: str):
        # Store hashed token
        self.paired_devices[device_id] = hashlib.sha256(token.encode()).hexdigest()
        self.save()

    def validate(self, device_id: str, token: str) -> bool:
        stored_hash = self.paired_devices.get(device_id)
        if not stored_hash:
            return False
        incoming_hash = hashlib.sha256(token.encode()).hexdigest()
        # Constant-time comparison (prevents timing attacks)
        return hmac.compare_digest(incoming_hash, stored_hash)

    def is_first_connection(self) -> bool:
        return len(self.paired_devices) == 0
```

---

## D7. System Tray Icon

```python
# tray/tray_icon.py

import pystray
from PIL import Image, ImageDraw
import threading

class TrayIcon:

    def __init__(self, on_quit=None, on_settings=None):
        self.on_quit = on_quit
        self.on_settings = on_settings
        self._icon = None
        self._connected = False

    def show(self):
        image = self._create_icon(connected=False)
        menu = pystray.Menu(
            pystray.MenuItem('HumanType Bridge', None, enabled=False),
            pystray.MenuItem('Status: Waiting...', None, enabled=False),
            pystray.Menu.SEPARATOR,
            pystray.MenuItem('Open Windows App', self._open_app),
            pystray.MenuItem('Quit', self._quit),
        )
        self._icon = pystray.Icon('HumanType', image, 'HumanType Bridge', menu)
        # Run in background thread so it doesn't block asyncio
        thread = threading.Thread(target=self._icon.run, daemon=True)
        thread.start()

    def set_connected(self, device_name: str):
        self._connected = True
        self._icon.icon = self._create_icon(connected=True)
        self._icon.title = f'HumanType — {device_name}'

    def set_disconnected(self):
        self._connected = False
        self._icon.icon = self._create_icon(connected=False)
        self._icon.title = 'HumanType Bridge — Waiting'

    def _create_icon(self, connected: bool) -> Image.Image:
        # Create a simple 64x64 icon
        img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        color = (46, 204, 113) if connected else (231, 76, 60)  # Green/Red
        draw.ellipse([8, 8, 56, 56], fill=color)
        return img

    def _quit(self, icon, item):
        icon.stop()
        if self.on_quit:
            self.on_quit()

    def _open_app(self, icon, item):
        import subprocess
        subprocess.Popen(['humantype_windows.exe'])
```

---

## D8. Window Focus Detector

```python
# window_monitor/focus_detector.py
# Detects which app is active on the laptop
# Sends window info to Windows Flutter App via localhost WebSocket

import win32gui
import win32process
import psutil
import asyncio

class FocusDetector:

    def __init__(self, on_focus_change):
        self.on_focus_change = on_focus_change
        self._last_hwnd = None

    async def start_monitoring(self):
        while True:
            hwnd = win32gui.GetForegroundWindow()
            if hwnd != self._last_hwnd:
                self._last_hwnd = hwnd
                info = self._get_window_info(hwnd)
                if info:
                    await self.on_focus_change(info)
            await asyncio.sleep(0.5)  # Check every 500ms

    def _get_window_info(self, hwnd: int) -> dict:
        try:
            title = win32gui.GetWindowText(hwnd)
            _, pid = win32process.GetWindowThreadProcessId(hwnd)
            process = psutil.Process(pid)
            return {
                'hwnd': hwnd,
                'title': title,
                'process_name': process.name(),
                'process_path': process.exe(),
            }
        except Exception:
            return None
```

---

## D9. PyInstaller Packaging

```python
# humantype_bridge.spec

block_cipher = None

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=[
        'zeroconf._utils.ipaddress',
        'zeroconf._dns',
        'pystray._win32',
        'win32api', 'win32con', 'win32gui', 'win32process',
    ],
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    cipher=block_cipher,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz, a.scripts, a.binaries, a.zipfiles, a.datas,
    name='HumanTypeBridge',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,          # No console window — silent background
    icon='assets/icon.ico',
)
```

---

# PART C — WINDOWS FLUTTER APP

---

## C1. App Architecture

**Framework:** Flutter for Windows (3.16+)  
**State:** Riverpod 2.x  
**Navigation:** GoRouter  
**Windows APIs:** `win32` package + native method channels  
**Key native calls:** WDA_EXCLUDEFROMCAPTURE, SetWindowPos (TOPMOST), Windows OCR API

---

## C2. Main App Window

### C2.1 Layout — Sidebar + Content

```
┌────────────────────────────────────────────────────────────────┐
│  HumanType                                          ─  □  ✕   │
├──────────┬─────────────────────────────────────────────────────┤
│          │                                                      │
│  🏠      │                                                      │
│  Home    │                                                      │
│          │              CONTENT AREA                           │
│  📝      │        (switches based on nav)                      │
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

**Sidebar:** 60px collapsed (icons only) → 220px expanded (icons + labels on hover).

### C2.2 Dashboard Screen

```dart
// dashboard_screen.dart

class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(connectionProvider);
    final session = ref.watch(sessionProvider);

    return Column(
      children: [
        // Connection status bar
        ConnectionStatusBar(connection: conn),

        // Active session card
        if (session.isActive)
          SessionStatusCard(session: session)
        else
          NoSessionCard(),

        // Quick actions row
        QuickActionsRow(
          onCapture: () => ref.read(ocrProvider.notifier).captureScreen(),
          onCalibrate: () => context.push('/calibrate'),
          onStealth: () => ref.read(stealthProvider.notifier).toggle(),
        ),
      ],
    );
  }
}
```

### C2.3 Settings Screen — Full Panel

```dart
// settings_screen.dart

// All settings accessible here, synced to Android via WebSocket

class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        SettingsSection(title: 'Typing', children: [
          SpeedProfileSetting(),      // Default speed profile
          ErrorRateSetting(),         // Default errors per line
          ErrorTypeSetting(),         // Which error types allowed
          CorrectionStyleSetting(),   // When to correct errors
          FatigueSimulationToggle(),  // Fatigue simulation on/off
          BurstTypingToggle(),        // Fast digraphs on/off
        ]),
        SettingsSection(title: 'Connection', children: [
          PairedDevicesList(),        // Show paired Android devices
          AutoConnectToggle(),        // Auto-connect on startup
          WiFiPortSetting(),          // Port override (default 8765)
          BluetoothToggle(),          // Enable BT fallback
        ]),
        SettingsSection(title: 'Overlay', children: [
          OverlayPositionSetting(),   // Default corner (TL/TR/BL/BR)
          OverlayOpacitySetting(),    // 20–100%
          AutoCollapseSetting(),      // Delay before auto-collapse
          ShortcutsSetting(),         // Keyboard shortcut config
        ]),
        SettingsSection(title: 'AI', children: [
          ClaudeApiKeySetting(),      // API key input (obscured)
          AiFeaturesToggle(),         // Enable/disable cloud AI
        ]),
        SettingsSection(title: 'Privacy & Advanced', children: [
          HistoryLoggingToggle(),     // Session history on/off
          StealthProcessNameSetting(),// Process name in stealth mode
          BridgeCompatibilityCheck(), // Check WDA support
          AboutSection(),
        ]),
      ],
    );
  }
}
```

---

## C3. Screen Overlay System

### C3.1 Architecture — Separate Flutter Window

The overlay is **NOT** a widget inside the main app. It is a completely **separate Flutter window** spawned at startup.

```dart
// main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  runApp(const ProviderScope(child: HumanTypeWindowsApp()));

  // Spawn overlay as separate window AFTER main app starts
  _spawnOverlayWindow();
}

void _spawnOverlayWindow() {
  // Overlay runs in same process but separate window
  // Uses multi-window approach via method channel
  // OR: use a second isolate with its own Flutter engine
  OverlayWindowManager.spawn();
}
```

### C3.2 WDA_EXCLUDEFROMCAPTURE Implementation

```dart
// overlay/wda_manager.dart

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WdaManager {

  /// Apply WDA_EXCLUDEFROMCAPTURE to a window.
  /// This makes the window invisible to ALL screen recording software
  /// while remaining fully visible on the physical monitor.
  ///
  /// Requires Windows 10 v2004 (build 19041) or later.
  /// WDA_EXCLUDEFROMCAPTURE = 0x00000011
  static bool applyExcludeFromCapture(int hwnd) {
    const WDA_EXCLUDEFROMCAPTURE = 0x00000011;
    final result = SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE);

    if (result == 0) {
      final error = GetLastError();
      debugPrint('[WDA] Failed to set WDA_EXCLUDEFROMCAPTURE: error $error');
      return false;
    }

    debugPrint('[WDA] WDA_EXCLUDEFROMCAPTURE applied to HWND $hwnd');
    return true;
  }

  /// Make window always on top of all other windows
  static void applyAlwaysOnTop(int hwnd) {
    SetWindowPos(
      hwnd,
      HWND_TOPMOST,
      0, 0, 0, 0,
      SWP_NOMOVE | SWP_NOSIZE,
    );
  }

  /// Remove window from taskbar and Alt+Tab switcher
  static void removeFromTaskbar(int hwnd) {
    final exStyle = GetWindowLongPtr(hwnd, GWL_EXSTYLE);
    SetWindowLongPtr(
      hwnd,
      GWL_EXSTYLE,
      exStyle | WS_EX_TOOLWINDOW & ~WS_EX_APPWINDOW,
    );
  }

  /// Check if current Windows version supports WDA_EXCLUDEFROMCAPTURE
  /// Requires build >= 19041 (Windows 10 v2004)
  static bool isCompatible() {
    // Use win32 VerifyVersionInfo or RtlGetVersion
    final osvi = calloc<OSVERSIONINFOEXW>();
    try {
      osvi.ref.dwOSVersionInfoSize = sizeOf<OSVERSIONINFOEXW>();
      RtlGetVersion(osvi);
      final build = osvi.ref.dwBuildNumber;
      debugPrint('[WDA] Windows build: $build');
      return build >= 19041;
    } finally {
      free(osvi);
    }
  }

  /// Apply all overlay window settings at once
  static Future<void> setupOverlayWindow(int hwnd) async {
    applyAlwaysOnTop(hwnd);
    removeFromTaskbar(hwnd);
    final wdaApplied = applyExcludeFromCapture(hwnd);
    if (!wdaApplied) {
      // Show one-time warning — overlay will be visible in recordings
      _notifyWdaUnsupported();
    }
  }

  static void _notifyWdaUnsupported() {
    // Store flag, show warning on next overlay open
    // "Stealth mode requires Windows 10 v2004 or later"
  }
}
```

### C3.3 Overlay Window Manager

```dart
// overlay/overlay_window.dart

class OverlayWindowManager {

  static const _defaultSize = Size(220, 48);  // Collapsed size
  static const _expandedSize = Size(240, 320); // Expanded size
  static const _stealthSize = Size(12, 12);    // Stealth dot size

  static OverlayState _state = OverlayState.collapsed;
  static Offset _position = const Offset(20, 20); // From top-right

  static Future<void> spawn() async {
    // Create borderless, transparent window
    await windowManager.setAsFrameless();
    await windowManager.setSize(_defaultSize);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setSkipTaskbar(true);

    // Get HWND and apply WDA
    final hwnd = await _getHwnd();
    await WdaManager.setupOverlayWindow(hwnd);

    // Position to top-right corner by default
    await _positionToCorner(Corner.topRight);
  }

  static Future<int> _getHwnd() async {
    // Use win32 FindWindow or GetForegroundWindow after brief delay
    await Future.delayed(const Duration(milliseconds: 100));
    return FindWindow(nullptr, TEXT('HumanType Overlay'));
  }

  static Future<void> expand() async {
    _state = OverlayState.expanded;
    await windowManager.setSize(_expandedSize);
  }

  static Future<void> collapse() async {
    _state = OverlayState.collapsed;
    await windowManager.setSize(_defaultSize);
  }

  static Future<void> enterStealth() async {
    _state = OverlayState.stealth;
    await windowManager.setSize(_stealthSize);
  }

  static Future<void> _positionToCorner(Corner corner) async {
    final screenSize = await ScreenRetriever.instance.getCursorScreenSize();
    Offset position;
    switch (corner) {
      case Corner.topRight:
        position = Offset(screenSize.width - _defaultSize.width - 20, 20);
      case Corner.topLeft:
        position = const Offset(20, 20);
      case Corner.bottomRight:
        position = Offset(screenSize.width - _defaultSize.width - 20,
            screenSize.height - _defaultSize.height - 60);
      case Corner.bottomLeft:
        position = Offset(20, screenSize.height - _defaultSize.height - 60);
    }
    await windowManager.setPosition(position);
  }
}
```

### C3.4 Overlay UI Widget Tree

```dart
// overlay/overlay_ui.dart

class OverlayUI extends ConsumerStatefulWidget {
  @override
  ConsumerState<OverlayUI> createState() => _OverlayUIState();
}

class _OverlayUIState extends ConsumerState<OverlayUI> {

  @override
  Widget build(BuildContext context) {
    final conn = ref.watch(connectionProvider);
    final session = ref.watch(sessionProvider);
    final overlay = ref.watch(overlayStateProvider);

    return GestureDetector(
      onPanUpdate: _handleDrag,
      onTap: _toggleExpanded,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: HumanTypeColors.bgElevated.withOpacity(0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HumanTypeColors.borderDefault),
          boxShadow: [
            BoxShadow(color: Colors.black38, blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: overlay.isExpanded ? _buildExpanded(conn, session) : _buildCollapsed(conn),
      ),
    );
  }

  // COLLAPSED STATE: "🟢 HT  ≡"
  Widget _buildCollapsed(ConnectionState conn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConnectionDot(quality: conn.quality),
          const SizedBox(width: 8),
          Text('HT', style: HumanTypeText.caption.copyWith(color: Colors.white70)),
          const SizedBox(width: 8),
          Icon(PhosphorIcons.list, size: 16, color: Colors.white54),
        ],
      ),
    );
  }

  // EXPANDED STATE: full controls
  Widget _buildExpanded(ConnectionState conn, SessionState session) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(children: [
            ConnectionDot(quality: conn.quality),
            const SizedBox(width: 6),
            Text('HumanType', style: HumanTypeText.caption),
            const Spacer(),
            GestureDetector(
              onTap: _toggleExpanded,
              child: Icon(PhosphorIcons.minus, size: 14, color: Colors.white38),
            ),
          ]),

          const Divider(height: 16, color: HumanTypeColors.borderSubtle),

          // Session progress
          if (session.isActive) ...[
            Text('Section ${session.currentSectionIndex + 1} / ${session.sections.length}',
              style: HumanTypeText.caption),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: session.progress,
              backgroundColor: HumanTypeColors.borderSubtle,
              valueColor: const AlwaysStoppedAnimation(HumanTypeColors.accentPrimary),
            ),
            const Divider(height: 16, color: HumanTypeColors.borderSubtle),
          ],

          // Control buttons
          _OverlayButton(
            icon: session.isExecuting ? PhosphorIcons.pause : PhosphorIcons.play,
            label: session.isExecuting ? 'PAUSE' : 'START',
            onTap: () => session.isExecuting
              ? ref.read(sessionProvider.notifier).pause()
              : ref.read(sessionProvider.notifier).start(),
          ),
          const SizedBox(height: 4),
          _OverlayButton(
            icon: PhosphorIcons.stop,
            label: 'STOP',
            color: HumanTypeColors.accentDanger,
            onTap: () => ref.read(sessionProvider.notifier).stop(),
          ),

          const Divider(height: 16, color: HumanTypeColors.borderSubtle),

          // Quick settings
          _SpeedRow(),
          const SizedBox(height: 4),
          _ErrorRow(),

          const Divider(height: 16, color: HumanTypeColors.borderSubtle),

          // Actions
          _OverlayButton(
            icon: PhosphorIcons.camera,
            label: 'Capture Screen',
            onTap: () => ref.read(ocrProvider.notifier).captureScreen(),
          ),
          const SizedBox(height: 4),
          _OverlayButton(
            icon: PhosphorIcons.gear,
            label: 'Open Settings',
            onTap: () => ref.read(mainWindowProvider.notifier).show(),
          ),
          const SizedBox(height: 4),
          _OverlayButton(
            icon: PhosphorIcons.eyeSlash,
            label: 'Stealth Mode',
            onTap: () => ref.read(stealthProvider.notifier).toggle(),
          ),

          // ETA if active
          if (session.isActive) ...[
            const Divider(height: 16, color: HumanTypeColors.borderSubtle),
            Text('Next: Section ${session.currentSectionIndex + 2}',
              style: HumanTypeText.caption.copyWith(color: Colors.white38)),
            Text('ETA: ~${session.etaSeconds}s',
              style: HumanTypeText.caption.copyWith(color: Colors.white38)),
          ],
        ],
      ),
    );
  }

  void _handleDrag(DragUpdateDetails details) {
    OverlayWindowManager.moveBy(details.delta);
  }

  void _toggleExpanded() {
    final isExpanded = ref.read(overlayStateProvider).isExpanded;
    if (isExpanded) {
      OverlayWindowManager.collapse();
    } else {
      OverlayWindowManager.expand();
    }
  }
}
```

### C3.5 Keyboard Shortcuts for Overlay

```dart
// Register global keyboard shortcuts (work even when app not focused)
// Use win32 RegisterHotKey API

class GlobalShortcutManager {

  static void register() {
    // Ctrl+Shift+H — Toggle overlay expand/collapse
    RegisterHotKey(NULL, 1, MOD_CONTROL | MOD_SHIFT, 0x48); // H

    // Ctrl+Shift+S — Toggle stealth mode
    RegisterHotKey(NULL, 2, MOD_CONTROL | MOD_SHIFT, 0x53); // S

    // Ctrl+Shift+P — Pause/Resume typing
    RegisterHotKey(NULL, 3, MOD_CONTROL | MOD_SHIFT, 0x50); // P

    // Ctrl+Shift+X — Emergency stop
    RegisterHotKey(NULL, 4, MOD_CONTROL | MOD_SHIFT, 0x58); // X

    // Ctrl+Shift+C — Capture screen OCR
    RegisterHotKey(NULL, 5, MOD_CONTROL | MOD_SHIFT, 0x43); // C
  }
}
```

---

## C4. Stealth / Demo Mode

```dart
// stealth/stealth_manager.dart

class StealthManager extends Notifier<StealthState> {

  @override
  StealthState build() => StealthState.normal;

  Future<void> activate() async {
    // Step 1: Minimize main window to tray
    await windowManager.hide();

    // Step 2: Change tray icon to neutral
    ref.read(trayProvider.notifier).setNeutralIcon();

    // Step 3: Collapse overlay to 12x12 dot
    await OverlayWindowManager.enterStealth();

    // Step 4: Change process display name
    _changeProcessName('RuntimeHost');

    // Step 5: Notify Android app
    ref.read(androidSyncProvider).sendSettingsSync(
      'stealth_mode', true
    );

    state = StealthState.active;
  }

  Future<void> deactivate() async {
    await windowManager.show();
    ref.read(trayProvider.notifier).setNormalIcon();
    await OverlayWindowManager.collapse();
    _changeProcessName('HumanType');
    ref.read(androidSyncProvider).sendSettingsSync('stealth_mode', false);
    state = StealthState.normal;
  }

  void _changeProcessName(String name) {
    // Use win32 to change process description in Task Manager
    // SetConsoleTitleW or custom implementation
    using((arena) {
      final namePtr = name.toNativeUtf16(allocator: arena);
      SetConsoleTitle(namePtr);
    });
  }
}
```

---

## C5. Screen OCR & Capture

```dart
// ocr/screenshot_service.dart

class ScreenshotService {

  /// Capture active window only
  Future<Uint8List> captureActiveWindow() async {
    final hwnd = GetForegroundWindow();
    return await _captureWindow(hwnd);
  }

  /// Capture full screen
  Future<Uint8List> captureFullScreen() async {
    final screenshot = await ScreenRetriever.instance.capture();
    return screenshot!.buffer.asUint8List();
  }

  /// Hide overlay briefly, capture, show overlay again
  Future<Uint8List> captureWithOverlayHidden() async {
    // Hide overlay (300ms)
    await OverlayWindowManager.temporarilyHide(Duration(milliseconds: 300));

    // Wait for hide animation
    await Future.delayed(const Duration(milliseconds: 350));

    // Capture
    final bytes = await captureActiveWindow();

    // Overlay auto-shows after temporarilyHide duration

    return bytes;
  }

  Future<Uint8List> _captureWindow(int hwnd) async {
    // Win32: GetWindowRect + BitBlt to capture specific window
    final rect = calloc<RECT>();
    GetWindowRect(hwnd, rect);
    // ... BitBlt capture implementation
    free(rect);
    return Uint8List(0); // Return captured bytes
  }
}
```

```dart
// ocr/ocr_service.dart

class OcrService {

  /// Use Windows built-in OCR API (no install needed, high quality)
  Future<String> extractText(Uint8List imageBytes) async {
    // Call Windows.Media.Ocr via method channel
    const platform = MethodChannel('humantype/ocr');
    try {
      final result = await platform.invokeMethod<String>('extractText', {
        'imageBytes': imageBytes,
      });
      return result ?? '';
    } catch (e) {
      // Fallback to Tesseract
      return await _tesseractFallback(imageBytes);
    }
  }

  Future<String> _tesseractFallback(Uint8List imageBytes) async {
    // Write to temp file, run Tesseract
    final tempFile = File('${Directory.systemTemp.path}/capture.png');
    await tempFile.writeAsBytes(imageBytes);
    final result = await FlutterTesseractOcr.extractText(tempFile.path);
    await tempFile.delete();
    return result ?? '';
  }

  /// Full capture + OCR + send to Android pipeline
  Future<void> captureAndSend(WidgetRef ref) async {
    // 1. Capture (with overlay hidden)
    final screenshot = await ScreenshotService().captureWithOverlayHidden();

    // 2. OCR
    final text = await extractText(screenshot);
    if (text.isEmpty) return;

    // 3. Send to Android
    final windowInfo = await _getActiveWindowInfo();
    ref.read(androidSyncProvider).sendOcrResult(
      text: text,
      appName: windowInfo.processName,
      windowTitle: windowInfo.title,
    );

    // 4. Show brief success indicator in overlay
    ref.read(overlayStateProvider.notifier).showFlash('Sent to phone ✓');
  }
}
```

---

## C6. Field Calibration System

```dart
// calibration/screens/calibration_screen.dart

class CalibrationScreen extends ConsumerStatefulWidget { ... }

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {

  List<MappedField> _fields = [];
  Uint8List? _screenshot;
  Size? _screenshotSize;

  @override
  void initState() {
    super.initState();
    _captureForCalibration();
  }

  Future<void> _captureForCalibration() async {
    // Refresh every 2 seconds
    final bytes = await ScreenshotService().captureFullScreen();
    setState(() => _screenshot = bytes);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) _captureForCalibration(); // Loop
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Live screen mirror with clickable fields
        Expanded(
          flex: 3,
          child: _screenshot != null
            ? GestureDetector(
                onTapDown: (details) => _addField(details.localPosition),
                child: Stack(
                  children: [
                    Image.memory(_screenshot!, fit: BoxFit.contain),
                    // Show mapped fields as colored pins
                    ..._fields.map((f) => _buildFieldPin(f)),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
        ),

        // Field list panel
        SizedBox(
          width: 280,
          child: Column(
            children: [
              Text('Mapped Fields', style: HumanTypeText.heading2),
              const SizedBox(height: 16),
              ..._fields.map((f) => _buildFieldItem(f)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveFieldMap,
                child: const Text('Save Field Map'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addField(Offset tapPosition) {
    // Convert tap position to percentage of screenshot dimensions
    final xPercent = tapPosition.dx / _screenshotSize!.width;
    final yPercent = tapPosition.dy / _screenshotSize!.height;

    setState(() {
      _fields.add(MappedField(
        id: const Uuid().v4(),
        name: 'Field ${_fields.length + 1}',
        xPercent: xPercent,
        yPercent: yPercent,
      ));
    });
  }

  Future<void> _saveFieldMap() async {
    final windowInfo = await FocusDetector().getCurrentWindow();
    final fieldMap = FieldMapModel(
      id: const Uuid().v4(),
      appName: windowInfo.processName,
      windowTitle: windowInfo.title,
      fields: _fields,
      createdAt: DateTime.now(),
    );
    await ref.read(calibrationProvider.notifier).save(fieldMap);
    if (mounted) context.pop();
  }
}
```

---

## C7. Android Sync Service

```dart
// sync/android_sync_service.dart

class AndroidSyncService {

  final WiFiService _wifi;

  void sendOcrResult({
    required String text,
    required String appName,
    required String windowTitle,
  }) {
    _wifi.send(WsMessage(
      type: MessageType.ocrResult,
      sender: DeviceInfo.windows(),
      payload: {
        'text': text,
        'app_name': appName,
        'window_title': windowTitle,
      },
    ));
  }

  void sendSettingsSync(String key, dynamic value) {
    _wifi.send(WsMessage(
      type: MessageType.settingsSync,
      sender: DeviceInfo.windows(),
      payload: {
        'changed_key': key,
        'new_value': value,
        'source_device': 'windows',
      },
    ));
  }

  // Handle incoming messages from Android
  void handleIncoming(WsMessage message) {
    switch (message.type) {
      case MessageType.settingsSync:
        _applySettingsChange(message.payload);
      case MessageType.sessionControl:
        _relayTobridge(message);  // Forward to bridge via localhost WS
      default:
        break;
    }
  }
}
```

---

## C8. UI/UX Design System — Windows

**Use the same color system, typography, and spacing as Agent 1 (see PART F below).**

### Windows-Specific Design Rules

1. **Minimum window size:** 900×600px. App adapts layout for wider screens.
2. **Sidebar:** 60px icon-only, expands to 220px on hover with labels.
3. **Mica/Acrylic effect:** Background has subtle blur/acrylic effect (Windows 11 style).
4. **Fluent Design tokens:** Use `fluent_ui` package for native Windows feel where appropriate.
5. **Title bar:** Custom title bar with integrated connection status indicator.
6. **Overlay:** Completely separate window — not a widget inside the app.
7. **Always-on-top overlay:** Never clips behind other windows.
8. **Right-click on overlay:** Context menu for opacity, position reset, close.

### Windows Theme Setup

```dart
// core/theme.dart — Windows

FluentThemeData buildWindowsTheme() {
  return FluentThemeData(
    brightness: Brightness.dark,
    accentColor: AccentColor.swatch({
      'darkest': const Color(0xFF3D37B3),
      'darker':  const Color(0xFF4D47C3),
      'dark':    const Color(0xFF5C56D4),
      'normal':  const Color(0xFF6C63FF),  // Brand accent
      'light':   const Color(0xFF8B84FF),
      'lighter': const Color(0xFFABA5FF),
      'lightest':const Color(0xFFCAC7FF),
    }),
    scaffoldBackgroundColor: const Color(0xFF0A0A0F),
    cardColor: const Color(0xFF1A1A24),
    typography: Typography.raw(
      body: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      bodyLarge: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      subtitle: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      title: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
    ),
  );
}
```

---

# PART E — COMMUNICATION PROTOCOL (Shared Contract with Agent 1)

> ⚠️ This protocol is the exact same spec Agent 1 is coding to.
> Do NOT deviate from these message formats.

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

## E2. All Message Types Bridge Handles

```python
# Python — message_types as strings
MESSAGE_TYPES = {
  # You RECEIVE these (from Android):
  'handshake',              # First connection message
  'cmd',                    # Single character/key to type
  'session_control',        # Start/pause/resume/abort
  'heartbeat',              # Keep-alive ping
  'capability_advertisement',

  # You SEND these (to Android):
  'handshake_ack',
  'heartbeat_ack',
  'cmd_ack',
  'progress',               # Typing progress update
  'capability_advertisement',
  'unsupported',            # Unknown message type received
}
```

## E3. Key Payloads

```python
# CMD — you receive this and execute
{
  "action": "CHAR",         # or SPECIAL_KEY, HOTKEY, PAUSE, CLICK
  "char": "h",              # For CHAR
  "key": "enter",           # For SPECIAL_KEY
  "keys": ["ctrl", "s"],    # For HOTKEY
  "delay_pre_ms": 85,       # Delay BEFORE executing this command
  "x": 452, "y": 312        # For CLICK
}

# PROGRESS — you send to Android periodically
{
  "chars_sent": 847,
  "chars_total": 1263,
  "section_index": 1,
  "sections_total": 4,
  "current_wpm": 68,
  "eta_seconds": 45
}

# SESSION_CONTROL — you receive and act on
{
  "action": "PAUSE" | "RESUME" | "ABORT"
}

# OCR_RESULT — Windows App sends to Android (not bridge)
{
  "text": "...",
  "app_name": "Google Chrome",
  "window_title": "Question 3 of 10"
}

# SETTINGS_SYNC — bidirectional Windows ↔ Android
{
  "changed_key": "typing.speed_profile",
  "new_value": "fast",
  "source_device": "android"
}
```

---

# PART F — UI/UX DESIGN SYSTEM (Same as Agent 1)

## F1. Colors (Use These Exact Values)

```dart
class HumanTypeColors {
  static const bgPrimary    = Color(0xFF0A0A0F);
  static const bgSecondary  = Color(0xFF111118);
  static const bgElevated   = Color(0xFF1A1A24);
  static const bgOverlay    = Color(0xFF22222E);
  static const borderSubtle  = Color(0xFF2A2A3A);
  static const borderDefault = Color(0xFF3A3A4E);
  static const accentPrimary   = Color(0xFF6C63FF);
  static const accentSecondary = Color(0xFF4ECDC4);
  static const accentDanger    = Color(0xFFFF6B6B);
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);
  static const error   = Color(0xFFE74C3C);
}
```

## F2. Typography

```dart
class HumanTypeText {
  static TextStyle display    = GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700);
  static TextStyle heading1   = GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600);
  static TextStyle heading2   = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle body       = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle caption    = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500);
  static TextStyle mono       = GoogleFonts.jetBrainsMono(fontSize: 13);
}
```

## F3. Spacing Grid (4px base, same as Agent 1)

```dart
class HumanTypeSpacing {
  static const xs = 4.0; static const sm = 8.0;
  static const md = 12.0; static const lg = 16.0;
  static const xl = 24.0; static const xxl = 32.0;
}
```

## F4. Premium Feel Rules (Same as Agent 1)

1. Never show raw errors — always friendly message + action
2. Loading indicator for any action >100ms
3. Spacing grid strictly 4px multiples
4. Empty states have illustration + CTA
5. Every tap: scale animation (98% press for desktop)
6. Destructive actions require confirmation
7. Settings organized by mental model, not technical categories
8. Typography hierarchy strictly enforced
9. Overlay drag must feel smooth — no lag, no jitter
10. Overlay opacity changes must be instant (no animation delay)

---

# PART G — ENGINEERING STANDARDS

## G1. Performance Targets (Windows)

| Metric | Target |
|--------|--------|
| App startup | < 2s |
| Overlay appears after bridge ready | < 1s |
| Command latency (receive → keystroke) | < 20ms (localhost) |
| OCR capture to result sent | < 3s total |
| Memory — Windows app | < 200MB |
| Memory — Bridge (.exe) | < 50MB |
| Bridge CPU idle | < 0.5% |
| Bridge CPU typing | < 5% |
| Overlay frame rate | 60fps |

## G2. Windows Native APIs Used

| API | Purpose | Package |
|-----|---------|---------|
| `SetWindowDisplayAffinity` | WDA_EXCLUDEFROMCAPTURE | `win32` |
| `SetWindowPos` | Always-on-top (HWND_TOPMOST) | `win32` |
| `GetWindowLongPtr/SetWindowLongPtr` | Remove from taskbar | `win32` |
| `RegisterHotKey` | Global keyboard shortcuts | `win32` |
| `Windows.Media.Ocr` | Built-in OCR | Method channel |
| `GetForegroundWindow` | Active window detection | `win32` / `pywin32` |
| `RtlGetVersion` | Windows build number check | `win32` |
| `SetConsoleTitle` | Change process display name | `win32` |

## G3. Bridge Error Handling Rules

- Main loop wrapped in try-except — bridge NEVER crashes
- Unknown message types → log + send 'unsupported' response → continue
- `pyautogui` failure → log + send error to Windows app → pause execution
- Connection dropped → cleanup client → wait for reconnect
- All exceptions logged to local file `bridge_log.txt`

## G4. Security

- Token file stored in `%APPDATA%\HumanType\paired_devices.json`
- Token comparison uses `hmac.compare_digest` (constant-time)
- Bridge only accepts from subnet (127.0.0.0/8 rejected — localhost only for Windows app)
- Rate limit: max 2000 commands/minute from any single client
- 3 failed auth attempts → block that IP for 60 seconds

---

# PART H — DEVELOPMENT PHASES (Windows + Bridge Side)

### Phase 1 (Weeks 1–3): Foundation
- [ ] Python bridge: WebSocket server running on port 8765
- [ ] mDNS broadcast working
- [ ] Handshake + token validation
- [ ] Basic CMD execution (pyautogui.write)
- [ ] System tray icon (green/red status)
- [ ] Flutter Windows: basic app shell + connect to bridge via localhost
- **Milestone:** Bridge running, Android can connect + type Hello World

### Phase 2 (Weeks 4–7): Full Command Execution
- [ ] All command types: CHAR, SPECIAL_KEY, HOTKEY, CLICK
- [ ] PAUSE / RESUME / ABORT handling
- [ ] Progress reporting to Android
- [ ] Bluetooth server (PyBluez)
- [ ] Window focus detector
- **Milestone:** Full command execution working for all types

### Phase 3 (Weeks 8–10): Windows App Features
- [ ] Full dashboard UI
- [ ] Live session status from bridge
- [ ] Settings panel (all settings)
- [ ] Sync with Android app (settings)
- **Milestone:** Windows app fully functional for settings + monitoring

### Phase 4 (Weeks 11–13): Overlay
- [ ] Overlay window (separate Flutter window)
- [ ] WDA_EXCLUDEFROMCAPTURE applied
- [ ] All 4 overlay states (collapsed, expanded, stealth, disconnected)
- [ ] Drag to reposition
- [ ] Opacity control
- [ ] Keyboard shortcuts (RegisterHotKey)
- **Milestone:** Overlay visible, completely invisible in OBS recording

### Phase 5 (Weeks 14–15): Stealth Mode
- [ ] Full stealth activation sequence
- [ ] Process name change
- [ ] Tray icon change
- [ ] Notify Android
- **Milestone:** Stealth mode — nothing visible in screen recording

### Phase 6 (Weeks 16–17): OCR + Calibration
- [ ] Screenshot capture (active window + full screen)
- [ ] Windows OCR API method channel
- [ ] Tesseract fallback
- [ ] Send OCR result to Android
- [ ] Live screen mirror in calibration screen
- [ ] Field tapping + coordinate saving
- [ ] Field map auto-load on window focus change
- **Milestone:** Capture screen → text sent to Android in <3s

### Phase 7 (Weeks 18–20): Polish
- [ ] Full design system on all Windows screens
- [ ] First-launch setup wizard
- [ ] PyInstaller packaging (.exe, single file)
- [ ] Windows 10 + 11 testing
- [ ] WDA compatibility check + warning
- [ ] Full error handling
- **Milestone:** `.exe` distributed, beta-ready

---

*AGENT 2 — Windows App + Python Bridge Build Specification*
*HumanType v4.0 | Give this file to your Windows Flutter + Python AI*
*Agent 1 is building the Android APK in parallel*