class_name CameraController extends Node3D

@export_category("References")
@export var player_controller: PlayerController
@export var component_mouse_capture: MouseCaptureComponent
@export_category("Camera Settings")
@export_range(-90, -60) var tilt_lower_limit: int = -90
@export_range(60, 90) var tilt_upper_limit: int = 90

var _camera_euler: Vector3


func update_camera_rotation(input: Vector2) -> void:
	_camera_euler.x += input.y
	_camera_euler.y += input.x
	_camera_euler.x = clamp(_camera_euler.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))

	var player_rotation := Vector3(0.0, _camera_euler.y, 0.0)
	var camera_rotation := Vector3(_camera_euler.x, 0.0, 0.0)

	transform.basis = Basis.from_euler(camera_rotation)
	player_controller.update_rotation(player_rotation)

	_camera_euler.z = 0.0


func _process(_delta: float) -> void:
	update_camera_rotation(component_mouse_capture.get_mouse_input())
