import asyncio
import pyautogui
from executor.command_parser import ParsedCommand, ActionType

# Critical safety settings
pyautogui.FAILSAFE = False  # Disable mouse-corner emergency stop (bridge needs to run reliably)
pyautogui.PAUSE = 0         # We control ALL delays ourselves for human-like timing

class KeyboardExecutor:
    """
    Executes simulated keystrokes and mouse actions based on ParsedCommand objects.
    Handles precise human-like delays.
    """

    def __init__(self):
        # Mapping of special key names from protocol to pyautogui key names
        self.key_map = {
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

    async def execute(self, command: ParsedCommand):
        """Execute a parsed command with appropriate pre-delay."""
        
        # Apply the pre-command delay (this is the human timing logic)
        if command.delay_ms > 0:
            await asyncio.sleep(command.delay_ms / 1000.0)

        try:
            if command.action == ActionType.CHAR:
                if command.char:
                    # Use write for regular characters
                    pyautogui.write(command.char, interval=0)

            elif command.action == ActionType.SPECIAL_KEY:
                if command.key:
                    # Map the key if necessary, otherwise pass it directly
                    mapped_key = self.key_map.get(command.key.lower(), command.key)
                    pyautogui.press(mapped_key)

            elif command.action == ActionType.HOTKEY:
                if command.keys and len(command.keys) > 0:
                    pyautogui.hotkey(*command.keys)

            elif command.action == ActionType.CLICK:
                if command.x is not None and command.y is not None:
                    pyautogui.click(command.x, command.y)

            elif command.action == ActionType.PAUSE:
                # PAUSE commands just sleep (delay_ms is applied above)
                pass

        except Exception as e:
            print(f"[Executor] Error executing command: {e}")
