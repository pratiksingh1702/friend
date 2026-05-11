# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
['main.py'],
pathex=[],
binaries=[],
datas=[],
hiddenimports=[
# Core packages
'pyautogui',
'pystray',
'zeroconf',
'pynput',

# Zeroconf internals
'zeroconf._utils.ipaddress',
'zeroconf._dns',

# Pystray backend
'pystray._win32',

# Win32 modules
'win32api',
'win32con',
'win32gui',
'win32process',
'zeroconf._handlers.answers',
'zeroconf._handlers.multicast_outgoing_queue',
'zeroconf._handlers.query_handler',
'zeroconf._services.browser',
'zeroconf._services.info',

# PIL / Pillow
'PIL',
'PIL.Image',
'PIL.ImageTk',
],
hookspath=[],
hooksconfig={},
runtime_hooks=[],
excludes=[],
win_no_prefer_redirects=False,
win_private_assemblies=False,
cipher=block_cipher,
noarchive=False,
)

pyz = PYZ(
a.pure,
a.zipped_data,
cipher=block_cipher,
)

exe = EXE(
pyz,
a.scripts,
a.binaries,
a.zipfiles,
a.datas,
[],
name='HumanTypeBridge',
debug=False,
bootloader_ignore_signals=False,
strip=False,
upx=True,
upx_exclude=[],
runtime_tmpdir=None,
console=True,
disable_windowed_traceback=False,
argv_emulation=False,
target_arch=None,
codesign_identity=None,
entitlements_file=None,
icon=None,
)
