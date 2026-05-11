import asyncio
import sys
import os
from server.websocket_server import WebSocketServer
from discovery.mdns_broadcast import MdnsBroadcast
from tray.tray_icon import TrayIcon
from security.token_validator import TokenValidator

# Add current directory to path so imports work correctly when run directly
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

async def main():
    print("[Bridge] Starting HumanType Bridge...")

    # 1. Load stored pairing tokens
    validator = TokenValidator()
    validator.load()
    if validator.is_first_connection():
        print("[Bridge] No devices paired yet. Waiting for first connection...")
    else:
        print(f"[Bridge] Loaded {len(validator.paired_devices)} paired devices.")

    # 2. Setup System Tray
    loop = asyncio.get_running_loop()
    
    def on_quit():
        print("[Bridge] Shutting down...")
        # Cancel all running tasks
        for task in asyncio.all_tasks(loop):
            task.cancel()
            
    tray = TrayIcon(on_quit=on_quit)
    tray.show()

    # 3. Start mDNS broadcast (so Android can find us)
    mdns = MdnsBroadcast(port=8765)
    mdns.start()

    # 4. Start WebSocket server
    ws_server = WebSocketServer(validator=validator)

    try:
        # Run the websocket server (runs forever)
        await ws_server.start(host='0.0.0.0', port=8765)
    except asyncio.CancelledError:
        pass
    finally:
        print("[Bridge] Cleaning up...")
        mdns.stop()

if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n[Bridge] Exiting due to KeyboardInterrupt")
