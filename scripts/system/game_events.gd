## Global event bus — autoloaded as "GameEvents".
## Scripts emit and listen here without needing direct node references.
extends Node

## Emitted by PlayerController whenever the card hand changes.
## hand is an Array[CardType.Type] representing cards in order (index 0 = next to use).
signal card_hand_changed(hand: Array)
