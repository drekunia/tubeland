@tool
extends Control


@export var crosshair_size: float = 10.0
@export var line_width: float = 2.0
@export var color: Color = Color.WHITE

func _draw():
	draw_line(Vector2(0, -crosshair_size), Vector2(0, crosshair_size), color, line_width)
	draw_line(Vector2(-crosshair_size, 0), Vector2(crosshair_size, 0), color, line_width)

func _process(_delta):
	queue_redraw()
