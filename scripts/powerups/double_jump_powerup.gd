class_name DoubleJumpPowerup extends Area3D

@export var cards_to_give: int = 1
@export var float_amplitude: float = 0.25
@export var float_speed: float = 2.0
@export var spin_speed: float = 90.0

var _base_y: float
var _time: float = 0.0
var _initialized: bool = false   # wait until global_position is valid

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Capture the true world Y on the very first frame AFTER global_position
	# has been set by the spawner (add_child runs _ready before position is assigned).
	if not _initialized:
		_base_y = global_position.y
		_initialized = true

	_time += delta
	global_position.y = _base_y + sin(_time * float_speed) * float_amplitude
	rotate_y(deg_to_rad(spin_speed * delta))

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		if body.get_card_count() < body.max_cards:
			body.add_card(cards_to_give)
			queue_free()
