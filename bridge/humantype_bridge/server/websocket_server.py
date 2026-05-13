import asyncio
import json
import websockets
from executor.keyboard_executor import KeyboardExecutor
from executor.command_parser import CommandParser
from security.token_validator import TokenValidator

class WebSocketServer:
    """
    Handles incoming WebSocket connections, handshake validation, and command routing.
    """

    def __init__(self, validator: TokenValidator):
        self.validator = validator
        self.executor = KeyboardExecutor()
        self.parser = CommandParser()
        self.connected_clients = {}   # device_id -> (websocket, info)
        self._paused = False
        self._abort = False

    async def start(self, host: str, port: int):
        print(f"[Bridge] WebSocket server starting on ws://{host}:{port}")
        async with websockets.serve(self._handle_client, host, port):
            await asyncio.Future()  # run forever

    async def broadcast(self, message: dict, exclude_id: str = None):
        """Send a message to all connected clients."""
        payload = json.dumps(message)
        disconnected = []
        for dev_id, (ws, _) in self.connected_clients.items():
            if dev_id == exclude_id:
                continue
            try:
                await ws.send(payload)
            except:
                disconnected.append(dev_id)
        
        for dev_id in disconnected:
            self.connected_clients.pop(dev_id, None)

    async def _handle_client(self, websocket, path=None):
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
            device_id = sender.get('device_id', 'unknown')

            # Trust the local Windows Command Center
            is_authorized = device_id == 'windows-cmd-center'
            
            if not is_authorized:
                if not self.validator.validate(device_id, token):
                    # New device — store token (first-time pairing) if no devices paired
                    if self.validator.is_first_connection():
                        self.validator.store(device_id, token)
                        print(f"[Bridge] New device paired: {device_id}")
                    else:
                        await websocket.close(1008, 'Authentication failed')
                        return

            # Store client
            self.connected_clients[device_id] = (websocket, sender)
            print(f"[Bridge] Connected: {device_id} ({sender.get('device_type', 'unknown')})")

            # Send handshake ack to THE CLIENT
            await websocket.send(json.dumps({
                'type': 'handshake_ack',
                'sender': {'device_id': 'bridge', 'device_type': 'bridge', 'current_role': 'executor'},
                'payload': {'status': 'ok', 'bridge_version': '1.0.0'}
            }))

            # Broadcast registry update to EVERYONE
            await self.broadcast({
                'type': 'device_registry',
                'sender': {'device_id': 'bridge', 'device_type': 'bridge'},
                'payload': {
                    'devices': [info for _, info in self.connected_clients.values()]
                }
            })

            # Main command loop
            async for raw_message in websocket:
                await self._handle_message(json.loads(raw_message), device_id)

        except websockets.exceptions.ConnectionClosed:
            print(f"[Bridge] Disconnected: {device_id}")
        except asyncio.TimeoutError:
            print(f"[Bridge] Client handshake timed out.")
        except Exception as e:
            print(f"[Bridge] Error handling client: {e}")
        finally:
            if device_id and device_id in self.connected_clients:
                self.connected_clients.pop(device_id, None)
                # Notify others about departure
                await self.broadcast({
                    'type': 'device_registry',
                    'sender': {'device_id': 'bridge', 'device_type': 'bridge'},
                    'payload': {
                        'devices': [info for _, info in self.connected_clients.values()]
                    }
                })

    async def _handle_message(self, message: dict, sender_id: str):
        msg_type = message.get('type')
        print(f"[Bridge] Message from {sender_id}: {msg_type}")

        if msg_type == 'cmd':
            if not self._paused and not self._abort:
                payload = message.get('payload', {})
                print(f"[Bridge] Executing Command: {payload.get('text', '...')[:20]}")
                command = self.parser.parse(payload)
                
                # Report status back to observers (like Windows HUD)
                await self.broadcast({
                    'type': 'status_update',
                    'sender': {'device_id': 'bridge', 'device_type': 'bridge'},
                    'payload': {
                        'status': 'executing',
                        'progress': 0.5, 
                        'wpm': 65.0      
                    }
                })

                await self.executor.execute(command)
                
                # Send ACK to sender
                websocket, _ = self.connected_clients.get(sender_id, (None, None))
                if websocket:
                    msg_id = message.get('id')
                    await websocket.send(json.dumps({
                        'type': 'cmd_ack',
                        'id': msg_id
                    }))

        elif msg_type == 'session_control':
            action = message.get('payload', {}).get('action')
            print(f"[Bridge] Session Control: {action}")
            if action == 'START':
                 await self.broadcast({
                    'type': 'status_update',
                    'sender': {'device_id': 'bridge', 'device_type': 'bridge'},
                    'payload': {'status': 'executing', 'progress': 0, 'wpm': 0}
                })
            await self.broadcast(message, exclude_id=sender_id)

        elif msg_type == 'heartbeat':
            websocket, _ = self.connected_clients.get(sender_id, (None, None))
            if websocket:
                await websocket.send(json.dumps({'type': 'heartbeat_ack'}))

        elif msg_type == 'settings_sync':
            print(f"[Bridge] Syncing settings: {message.get('payload')}")
            await self.broadcast(message, exclude_id=sender_id)

        elif msg_type == 'ocr_result':
            print(f"[Bridge] Relaying OCR Result")
            await self.broadcast(message, exclude_id=sender_id)

        elif msg_type == 'live_text_sync':
            # Low latency relay for typing
            await self.broadcast(message, exclude_id=sender_id)
            
        elif msg_type == 'ai_completion':
            # Relay AI suggestions/results
            await self.broadcast(message, exclude_id=sender_id)
        
        elif msg_type == 'otp_detected':
            code = message.get('payload', {}).get('code')
            if code:
                print(f"[Bridge] Typing OTP: {code}")
                await self.executor.type_text(code, interval=0.05)
        
        elif msg_type == 'password_response':
            password = message.get('payload', {}).get('password')
            if password:
                print(f"[Bridge] Typing Password")
                await self.executor.type_text(password, interval=0.02)

        elif msg_type in ['scratchpad_sync', 'clipboard_sync', 'notification_mirror']:
            # Generic bidirectional sync relay
            await self.broadcast(message, exclude_id=sender_id)

        elif msg_type.startswith('file_transfer_') or msg_type.startswith('file_browse_'):
            # File related relay
            await self.broadcast(message, exclude_id=sender_id)

        elif msg_type == 'password_request':
            # Request from Windows -> Relay to Android
            await self.broadcast(message, exclude_id=sender_id)

        else:
            print(f"[Bridge] Unknown message: {msg_type}")
