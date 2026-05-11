import pystray
from PIL import Image, ImageDraw
import threading
import subprocess

class TrayIcon:
    """
    Manages the system tray icon for the Python Bridge.
    Runs in a separate thread so it doesn't block the main asyncio loop.
    """

    def __init__(self, on_quit=None):
        self.on_quit = on_quit
        self._icon = None
        self._connected = False

    def show(self):
        """Show the tray icon and start its message loop."""
        image = self._create_icon(connected=False)
        menu = pystray.Menu(
            pystray.MenuItem('HumanType Bridge', None, enabled=False),
            pystray.MenuItem('Status: Waiting...', None, enabled=False),
            pystray.Menu.SEPARATOR,
            pystray.MenuItem('Open Windows App', self._open_app),
            pystray.MenuItem('Quit', self._quit),
        )
        self._icon = pystray.Icon('HumanType', image, 'HumanType Bridge', menu)
        
        # Run in background thread
        thread = threading.Thread(target=self._icon.run, daemon=True)
        thread.start()

    def set_connected(self, device_name: str):
        """Update icon to show active connection."""
        if self._icon:
            self._connected = True
            self._icon.icon = self._create_icon(connected=True)
            self._icon.title = f'HumanType — Connected to {device_name}'

    def set_disconnected(self):
        """Update icon to show disconnected state."""
        if self._icon:
            self._connected = False
            self._icon.icon = self._create_icon(connected=False)
            self._icon.title = 'HumanType Bridge — Waiting'

    def _create_icon(self, connected: bool) -> Image.Image:
        """Draw a simple 64x64 circle icon (Green for connected, Red for waiting)."""
        img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        # Green if connected, Red if waiting/disconnected
        color = (46, 204, 113) if connected else (231, 76, 60)
        draw.ellipse([8, 8, 56, 56], fill=color)
        return img

    def _quit(self, icon, item):
        """Callback when 'Quit' is clicked."""
        icon.stop()
        if self.on_quit:
            self.on_quit()

    def _open_app(self, icon, item):
        """Callback to open the Flutter Windows app (if it exists)."""
        try:
            # Attempt to launch the Flutter app executable
            # This path assumes the bridge and app are deployed together or in PATH
            subprocess.Popen(['humantype_windows.exe'])
        except Exception as e:
            print(f"[Tray] Could not launch Windows app: {e}")
