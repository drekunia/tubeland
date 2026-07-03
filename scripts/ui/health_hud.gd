extends Control

var _health_label: Label

func _ready() -> void:
	_health_label = Label.new()
	_health_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_health_label.position = Vector2(20, -50)
	_health_label.add_theme_font_size_override("font_size", 32)
	_health_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2, 1))
	_health_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_health_label.add_theme_constant_override("outline_size", 4)
	add_child(_health_label)

	GameEvents.player_health_changed.connect(_on_health_changed)

func _on_health_changed(current: int, _max_health: int) -> void:
	var hearts = ""
	for i in range(current):
		hearts += "♥"
	_health_label.text = hearts
