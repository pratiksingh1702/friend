import socket
import platform
from zeroconf import ServiceInfo, Zeroconf

class MdnsBroadcast:
    """
    Broadcasts the HumanType service via mDNS (Bonjour/Zeroconf).
    Allows the Android app to discover the laptop on the local network automatically.
    """

    def __init__(self, port: int = 8765):
        self.port = port
        self.zeroconf = None
        self.info = None
        self.service_type = "_humantype._tcp.local."
        self.service_name = f"HumanTypeBridge._humantype._tcp.local."

    def start(self):
        """Start the mDNS broadcast."""
        try:
            local_ip = self._get_local_ip()
            hostname = socket.gethostname()
            
            self.info = ServiceInfo(
                self.service_type,
                self.service_name,
                addresses=[socket.inet_aton(local_ip)],
                port=self.port,
                properties={
                    b'device': hostname.encode(),
                    b'os': platform.system().encode(),
                    b'version': b'1.0.0',
                    b'type': b'bridge',
                }
            )
            
            self.zeroconf = Zeroconf()
            self.zeroconf.register_service(self.info)
            print(f"[mDNS] Broadcasting HumanType service at {local_ip}:{self.port}")
        except Exception as e:
            print(f"[mDNS] Failed to start broadcast: {e}")

    def stop(self):
        """Stop the mDNS broadcast and cleanup."""
        if self.zeroconf and self.info:
            print("[mDNS] Stopping broadcast...")
            self.zeroconf.unregister_service(self.info)
            self.zeroconf.close()
            self.zeroconf = None
            self.info = None

    def _get_local_ip(self) -> str:
        """Get the primary local IP address of this machine."""
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            # Doesn't actually connect, just used to find local IP
            s.connect(('8.8.8.8', 80))
            return s.getsockname()[0]
        except Exception:
            return "127.0.0.1"
        finally:
            s.close()
