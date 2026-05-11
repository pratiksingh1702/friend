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
        self.connected_clients = {}   # device_id -> websocket
        self._paused = False
        self._abort = False

    async def start(self, host: str, port: int):
        print(f"[Bridge] WebSocket server starting on ws://{host}:{port}")
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
            device_id = sender.get('device_id', 'unknown')

            if not self.validator.validate(device_id, token):
                # New device — store token (first-time pairing) if no devices paired
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

            # Send capabilities advertisement immediately after handshake
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
        except asyncio.TimeoutError:
            print(f"[Bridge] Client handshake timed out.")
        except Exception as e:
            print(f"[Bridge] Error handling client: {e}")
        finally:
            if device_id and device_id in self.connected_clients:
                self.connected_clients.pop(device_id, None)

    async def _handle_message(self, message: dict, websocket):
        msg_type = message.get('type')

        if msg_type == 'cmd':
            if not self._paused and not self._abort:
                command = self.parser.parse(message.get('payload', {}))
                await self.executor.execute(command)
                
                # Send ACK (ensure 'id' is echoed back to Android app)
                msg_id = message.get('id')
                if msg_id:
                    await websocket.send(json.dumps({
                        'type': 'cmd_ack',
                        'id': msg_id
                    }))

        elif msg_type == 'session_control':
            action = message.get('payload', {}).get('action')
            if action == 'PAUSE':
                self._paused = True
                print('[Bridge] Paused execution')
            elif action == 'RESUME':
                self._paused = False
                print('[Bridge] Resumed execution')
            elif action == 'ABORT':
                self._paused = False
                self._abort = True
                print('[Bridge] Aborted execution')

        elif msg_type == 'heartbeat':
            await websocket.send(json.dumps({'type': 'heartbeat_ack'}))

        elif msg_type == 'capability_advertisement':
            # Bridge ignores incoming capabilities from the app
            pass

        else:
            # Log unknown message type
            print(f"[Bridge] Unknown message type: {msg_type}")
            await websocket.send(json.dumps({
                'type': 'unsupported',
                'original_type': msg_type
            }))
