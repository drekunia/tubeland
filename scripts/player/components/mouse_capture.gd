class_name MouseCaptureComponent extends Node

@export_category("Mouse Capture Settings")
@export var current_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export_range(1.0, 10.0, 1.0) var mouse_sensitivity: float = 5.0

var _mouse_input: Vector2

func get_mouse_input() -> Vector2:
	return _mouse_input

func _ready() -> void:
	Input.mouse_mode = current_mouse_mode

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var current_sensitivity = GlobalSettings.mouse_sensitivity
		_mouse_input.x -= deg_to_rad(event.relative.x * current_sensitivity * 0.0125)
		_mouse_input.y -= deg_to_rad(event.relative.y * current_sensitivity * 0.0125)

	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	_mouse_input = Vector2.ZERO
