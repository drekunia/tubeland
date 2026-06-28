## Global event bus — autoloaded as "GameEvents".
## Scripts emit and listen here without needing direct node references.
extends Node

## Emitted by PlayerController whenever the Elevate card count changes.
signal cards_changed(count: int, max_count: int)
