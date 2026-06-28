## Displays Elevate card pips on the HUD, inspired by Neon White.
## Listens to GameEvents.cards_changed — no Inspector wiring required.
extends Control

# --- Visual config ---
const MAX_CARDS: int = 3
const CARD_WIDTH: float = 40.0
const CARD_HEIGHT: float = 54.0
const CARD_GAP: float = 8.0
const CARD_COLOR_FULL: Color = Color(0.35, 0.85, 1.0, 1.0)
const CARD_COLOR_EMPTY: Color = Color(0.15, 0.15, 0.2, 0.5)
const CARD_OUTLINE_COLOR: Color = Color(0.6, 0.9, 1.0, 0.8)
const GLOW_COLOR: Color = Color(0.35, 0.85, 1.0, 0.25)

var _card_count: int = 0
var _animated_scales: Array[float] = []
var _tween: Tween

func _ready() -> void:
	_animated_scales.resize(MAX_CARDS)
	_animated_scales.fill(1.0)
	GameEvents.cards_changed.connect(_on_cards_changed)

func _on_cards_changed(count: int, _max: int) -> void:
	var old_count = _card_count
	_card_count = count

	var changed_slot = count if count > old_count else old_count - 1
	changed_slot = clamp(changed_slot, 0, MAX_CARDS - 1)
	_pop_card(changed_slot)
	queue_redraw()

func _pop_card(slot: int) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_animated_scales[slot] = 1.3
	_tween.tween_method(
		func(v): _animated_scales[slot] = v; queue_redraw(),
		1.3, 1.0, 0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	var total_width = MAX_CARDS * CARD_WIDTH + (MAX_CARDS - 1) * CARD_GAP
	var start_x = (size.x - total_width) * 0.5
	var start_y = size.y - CARD_HEIGHT - 24.0

	for i in MAX_CARDS:
		var filled = i < _card_count
		var scale_factor = _animated_scales[i]
		var cx = start_x + i * (CARD_WIDTH + CARD_GAP) + CARD_WIDTH * 0.5
		var cy = start_y + CARD_HEIGHT * 0.5

		var w = CARD_WIDTH * scale_factor
		var h = CARD_HEIGHT * scale_factor
		var rect = Rect2(cx - w * 0.5, cy - h * 0.5, w, h)

		# Glow behind filled cards
		if filled:
			var glow_rect = Rect2(rect.position - Vector2(6, 6), rect.size + Vector2(12, 12))
			draw_rect(glow_rect, GLOW_COLOR, true, -1.0)

		# Card body
		draw_rect(rect, CARD_COLOR_FULL if filled else CARD_COLOR_EMPTY, true, -1.0)

		# Card outline
		draw_rect(rect, CARD_OUTLINE_COLOR, false, 1.5)

		# Arrow icon inside filled card
		if filled:
			_draw_arrow(cx, cy, w, h)

func _draw_arrow(cx: float, cy: float, w: float, h: float) -> void:
	var arrow_color = Color(1, 1, 1, 0.9)
	var aw = w * 0.35
	var ah = h * 0.4
	var shaft_w = aw * 0.4
	var shaft_h = ah * 0.55
	draw_rect(Rect2(cx - shaft_w * 0.5, cy - ah * 0.5 + ah * 0.45, shaft_w, shaft_h), arrow_color, true)
	var tip = Vector2(cx, cy - ah * 0.5)
	var bl = Vector2(cx - aw * 0.5, cy - ah * 0.5 + ah * 0.45)
	var br = Vector2(cx + aw * 0.5, cy - ah * 0.5 + ah * 0.45)
	draw_colored_polygon(PackedVector2Array([tip, bl, br]), arrow_color)
