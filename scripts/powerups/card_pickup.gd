## Generic card pickup — works for Elevate, Godspeed, and Fireball.
## Set card_type in the Inspector (or from target_dummy before add_child).
## Mesh and light color are applied automatically in _ready().
class_name CardPickup extends Area3D

@export var card_type: CardType.Type = CardType.Type.ELEVATE
@export var float_amplitude: float = 0.25
@export var float_speed: float = 2.0
@export var spin_speed: float = 90.0

# Visual color per card type
const CARD_COLORS: Dictionary = {
	CardType.Type.ELEVATE:  Color(1.00, 1.00, 0.00),  # yellow
	CardType.Type.GODSPEED: Color(0.20, 1.00, 0.50),  # green
	CardType.Type.FIREBALL: Color(1.00, 0.40, 0.10),  # orange
}

var _base_y: float
var _time: float = 0.0
var _initialized: bool = false

@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _light: OmniLight3D = $OmniLight3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_visuals()

func _apply_visuals() -> void:
	var color: Color = CARD_COLORS.get(card_type, Color.WHITE)

	if _mesh:
		var mat := StandardMaterial3D.new()
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 3.5
		mat.albedo_color = color
		_mesh.material_override = mat

	if _light:
		_light.light_color = color

func _process(delta: float) -> void:
	# Capture true world Y on the first frame AFTER global_position has been
	# set by the spawner (add_child calls _ready before position is assigned).
	if not _initialized:
		_base_y = global_position.y
		_initialized = true

	_time += delta
	global_position.y = _base_y + sin(_time * float_speed) * float_amplitude
	rotate_y(deg_to_rad(spin_speed * delta))

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		if body.add_card(card_type):
			queue_free()
