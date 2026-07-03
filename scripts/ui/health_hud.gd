extends Control

var _health_container: HBoxContainer
var _heart_texture: Texture2D

func _ready() -> void:
	_heart_texture = load("res://assets/textures/heart.svg")

	_health_container = HBoxContainer.new()
	_health_container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_health_container.position = Vector2(20, -50)
	_health_container.add_theme_constant_override("separation", 4)
	add_child(_health_container)

	GameEvents.player_health_changed.connect(_on_health_changed)

func _on_health_changed(current: int, _max_health: int) -> void:
	for child in _health_container.get_children():
		child.queue_free()

	for i in range(current):
		var tex = TextureRect.new()
		tex.texture = _heart_texture
		tex.custom_minimum_size = Vector2(32, 32)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_health_container.add_child(tex)
