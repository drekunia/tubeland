## Card hand HUD — displays up to 3 card slots at the bottom-center of the screen.
## Listens to GameEvents.card_hand_changed. No Inspector wiring required.
extends Control

# ── Layout constants ────────────────────────────────────────────────────────
const MAX_HAND: int = 3
const CARD_W: float = 40.0
const CARD_H: float = 54.0
const GAP: float = 8.0

const EMPTY_COLOR: Color = Color(0.12, 0.12, 0.16, 0.55)
const OUTLINE_COLOR: Color = Color(0.7, 0.7, 0.8, 0.6)
const ACTIVE_OUTLINE: Color = Color(1.0, 1.0, 1.0, 1.0)

# Per-type fill and glow colors
const FILL_COLORS: Dictionary = {
	CardType.Type.ELEVATE:  Color(1.00, 0.75, 0.00),
	CardType.Type.GODSPEED: Color(0.20, 1.00, 0.50),
	CardType.Type.FIREBALL: Color(1.00, 0.42, 0.12),
}
const GLOW_COLORS: Dictionary = {
	CardType.Type.ELEVATE:  Color(1.00, 0.75, 0.00, 0.22),
	CardType.Type.GODSPEED: Color(0.20, 1.00, 0.50, 0.22),
	CardType.Type.FIREBALL: Color(1.00, 0.42, 0.12, 0.22),
}
const LABEL_STRINGS: Dictionary = {
	CardType.Type.ELEVATE:  "ELV",
	CardType.Type.GODSPEED: "SPD",
	CardType.Type.FIREBALL: "FRB",
}

# ── State ────────────────────────────────────────────────────────────────────
var _hand: Array = []                    # Array[CardType.Type] mirrored from player
var _scales: Array[float] = [1.0, 1.0, 1.0]
var _tween: Tween

func _ready() -> void:
	GameEvents.card_hand_changed.connect(_on_hand_changed)

func _on_hand_changed(hand: Array) -> void:
	var old_size := _hand.size()
	_hand = hand.duplicate()

	# Pop animation: if gained a card animate last slot, if used animate slot 0
	var slot := _hand.size() if _hand.size() > old_size else 0
	slot = clamp(slot, 0, MAX_HAND - 1)
	_pop(slot)
	queue_redraw()

func _pop(slot: int) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_scales[slot] = 1.35
	_tween.tween_method(
		func(v: float) -> void: _scales[slot] = v; queue_redraw(),
		1.35, 1.0, 0.20
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# ── Drawing ──────────────────────────────────────────────────────────────────
func _draw() -> void:
	var total_w := MAX_HAND * CARD_W + (MAX_HAND - 1) * GAP
	var ox := (size.x - total_w) * 0.5
	var oy := size.y - CARD_H - 24.0

	for i in MAX_HAND:
		var filled: bool = i < _hand.size()
		var is_active: bool = (i == 0) and filled
		var sc: float = _scales[i]

		var cx := ox + i * (CARD_W + GAP) + CARD_W * 0.5
		var cy := oy + CARD_H * 0.5

		var w := CARD_W * sc
		var h := CARD_H * sc
		var rect := Rect2(cx - w * 0.5, cy - h * 0.5, w, h)

		if filled:
			var card_type: CardType.Type = _hand[i]

			# Glow halo
			var gr := Rect2(rect.position - Vector2(7, 7), rect.size + Vector2(14, 14))
			draw_rect(gr, GLOW_COLORS[card_type], true)

			# Card body
			draw_rect(rect, FILL_COLORS[card_type], true)

			# Brighter outline for the active (next-to-use) card
			draw_rect(rect, ACTIVE_OUTLINE if is_active else OUTLINE_COLOR, false,
					2.0 if is_active else 1.5)

			# Icon
			_draw_icon(card_type, cx, cy, w, h)
		else:
			draw_rect(rect, EMPTY_COLOR, true)
			draw_rect(rect, OUTLINE_COLOR, false, 1.0)

func _draw_icon(type: CardType.Type, cx: float, cy: float, w: float, h: float) -> void:
	var ic := Color(1, 1, 1, 0.92)
	var aw := w * 0.36
	var ah := h * 0.40

	match type:
		CardType.Type.ELEVATE:
			# ↑ upward arrow
			_arrow(cx, cy, aw, ah, 0.0, ic)

		CardType.Type.GODSPEED:
			# → rightward arrow (represents forward dash)
			_arrow(cx, cy, aw, ah, 90.0, ic)

		CardType.Type.FIREBALL:
			# ↗ diagonal arrow (aimed dash)
			_arrow(cx, cy, aw, ah, 45.0, ic)

## Draws an arrow pointing UP, then rotated by rot_deg around (cx, cy).
func _arrow(cx: float, cy: float, aw: float, ah: float,
		rot_deg: float, color: Color) -> void:
	var sw := aw * 0.38   # shaft width
	var tip := Vector2(0, -ah * 0.5)
	var bl  := Vector2(-aw * 0.5, -ah * 0.5 + ah * 0.44)
	var br  := Vector2( aw * 0.5, -ah * 0.5 + ah * 0.44)
	var shaft_tl := Vector2(-sw * 0.5, -ah * 0.5 + ah * 0.44)
	var shaft_br := Vector2( sw * 0.5,  ah * 0.5)

	var angle := deg_to_rad(rot_deg)
	var pts_head := PackedVector2Array([tip, bl, br])
	var pts_shaft := PackedVector2Array([
		shaft_tl, Vector2(sw * 0.5, -ah * 0.5 + ah * 0.44),
		shaft_br, Vector2(-sw * 0.5, ah * 0.5)
	])

	# Rotate and translate every point
	for arr in [pts_head, pts_shaft]:
		for j in arr.size():
			var p = arr[j]
			arr[j] = Vector2(
				p.x * cos(angle) - p.y * sin(angle) + cx,
				p.x * sin(angle) + p.y * cos(angle) + cy
			)

	draw_colored_polygon(pts_head, color)
	draw_colored_polygon(pts_shaft, color)
