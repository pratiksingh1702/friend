from dataclasses import dataclass
from enum import Enum
from typing import Optional, List

class ActionType(Enum):
    CHAR = 'CHAR'
    SPECIAL_KEY = 'SPECIAL_KEY'
    HOTKEY = 'HOTKEY'
    PAUSE = 'PAUSE'
    CLICK = 'CLICK'

@dataclass
class ParsedCommand:
    action: ActionType
    char: Optional[str] = None
    key: Optional[str] = None
    keys: Optional[List[str]] = None
    delay_ms: int = 0
    x: Optional[int] = None
    y: Optional[int] = None

class CommandParser:
    """
    Parses JSON payload dictionaries into structured ParsedCommand objects.
    Ensures safe extraction of command attributes.
    """
    
    def parse(self, payload: dict) -> ParsedCommand:
        action_str = payload.get('action', 'CHAR')
        
        try:
            action = ActionType(action_str)
        except ValueError:
            # Default to CHAR if action is unknown
            print(f"[CommandParser] Unknown action: {action_str}, defaulting to CHAR")
            action = ActionType.CHAR

        return ParsedCommand(
            action=action,
            char=payload.get('char'),
            key=payload.get('key'),
            keys=payload.get('keys', []),
            delay_ms=payload.get('delay_pre_ms', 0),
            x=payload.get('x'),
            y=payload.get('y'),
        )
