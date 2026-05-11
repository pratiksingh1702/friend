import hmac
import hashlib
import json
import os

class TokenValidator:
    """
    Handles storage and validation of pairing tokens for Android devices.
    Tokens are stored as SHA-256 hashes to prevent plain-text exposure.
    """
    
    TOKEN_FILE = 'paired_devices.json'

    def __init__(self):
        self.paired_devices = {}  # device_id -> token_hash

    def load(self):
        """Load paired devices from local storage."""
        if os.path.exists(self.TOKEN_FILE):
            try:
                with open(self.TOKEN_FILE, 'r') as f:
                    self.paired_devices = json.load(f)
            except Exception as e:
                print(f"[TokenValidator] Error loading tokens: {e}")
                self.paired_devices = {}

    def save(self):
        """Save paired devices to local storage."""
        try:
            with open(self.TOKEN_FILE, 'w') as f:
                json.dump(self.paired_devices, f, indent=4)
        except Exception as e:
            print(f"[TokenValidator] Error saving tokens: {e}")

    def store(self, device_id: str, token: str):
        """Hash and store a new pairing token."""
        self.paired_devices[device_id] = hashlib.sha256(token.encode()).hexdigest()
        self.save()

    def validate(self, device_id: str, token: str) -> bool:
        """
        Validate an incoming token against stored hash.
        Uses constant-time comparison to prevent timing attacks.
        """
        stored_hash = self.paired_devices.get(device_id)
        if not stored_hash:
            return False
        
        incoming_hash = hashlib.sha256(token.encode()).hexdigest()
        return hmac.compare_digest(incoming_hash, stored_hash)

    def is_first_connection(self) -> bool:
        """Returns True if no devices have been paired yet."""
        return len(self.paired_devices) == 0

    def remove_device(self, device_id: str):
        """Remove a paired device."""
        if device_id in self.paired_devices:
            del self.paired_devices[device_id]
            self.save()
