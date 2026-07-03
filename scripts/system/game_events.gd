## Global event bus — autoloaded as "GameEvents".
## Scripts emit and listen here without needing direct node references.
extends Node

## Emitted by PlayerController whenever the card hand changes.
## hand is an Array[CardType.Type] representing cards in order (index 0 = next to use).
@warning_ignore("unused_signal")
signal card_hand_changed(hand: Array)

@warning_ignore("unused_signal")
signal player_health_changed(current_health: int, max_health: int)

@warning_ignore("unused_signal")
signal player_died()

var current_checkpoint_position: Vector3 = Vector3.ZERO
var has_checkpoint: bool = false
var touched_checkpoints: Array[Vector2] = []

var run_start_time_msec: int = 0
var is_run_active: bool = false
var last_run_time: float = 0.0

func start_run() -> void:
	run_start_time_msec = Time.get_ticks_msec()
	is_run_active = true
	# Reset state just in case
	has_animated_level_two = false
	has_animated_level_three = false
	has_animated_level_four = false
	has_animated_level_five = false
	has_animated_level_six = false
	has_checkpoint = false
	touched_checkpoints.clear()
	saved_card_hand.clear()
	has_saved_card_hand = false
	saved_health = -1
	is_seamless_transition = false
	seamless_position = Vector3.ZERO
	seamless_velocity = Vector3.ZERO
	has_camera_euler = false

func stop_run() -> void:
	if is_run_active:
		last_run_time = (Time.get_ticks_msec() - run_start_time_msec) / 1000.0
		is_run_active = false
		if GlobalSettings.best_time <= 0.0 or last_run_time < GlobalSettings.best_time:
			GlobalSettings.best_time = last_run_time
			GlobalSettings.save_settings()

func get_current_run_time() -> float:
	if not is_run_active:
		return last_run_time
	return (Time.get_ticks_msec() - run_start_time_msec) / 1000.0


func set_checkpoint(pos: Vector3) -> void:
	current_checkpoint_position = pos
	has_checkpoint = true
	var pos2d = Vector2(pos.x, pos.z)
	var found = false
	for cp in touched_checkpoints:
		if cp.distance_to(pos2d) < 2.0:
			found = true
			break
	if not found:
		touched_checkpoints.append(pos2d)

var has_animated_level_two: bool = false
var has_animated_level_three: bool = false
var has_animated_level_four: bool = false
var has_animated_level_five: bool = false
var has_animated_level_six: bool = false

var saved_card_hand: Array = []
var has_saved_card_hand: bool = false
var saved_health: int = -1

func save_card_hand(hand: Array) -> void:
	saved_card_hand = hand.duplicate()
	has_saved_card_hand = true

var is_seamless_transition: bool = false
var seamless_position: Vector3 = Vector3.ZERO
var seamless_velocity: Vector3 = Vector3.ZERO

var initial_mouse_mode_set: bool = false

var current_camera_euler: Vector3 = Vector3.ZERO
var has_camera_euler: bool = false

func save_camera_euler(euler: Vector3) -> void:
	current_camera_euler = euler
	has_camera_euler = true
