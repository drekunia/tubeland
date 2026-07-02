class_name PlayerController extends CharacterBody3D

@export var melee_hitbox: ShapeCast3D
@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 35.0
@export var deceleration: float = 20.0

@export var max_health: int = 5

@export_group("Card Abilities")
## ELEVATE: upward burst velocity
@export var elevate_velocity: float = 8.0
## GODSPEED: horizontal dash speed
@export var godspeed_velocity: float = 24.0
## FIREBALL: full 3D dash speed toward crosshair
@export var fireball_velocity: float = 28.0
## Maximum cards held in hand at once
@export var max_hand_size: int = 3


# Ordered hand — index 0 is the next card to be used
var _card_hand: Array[CardType.Type] = []

var current_health: int
var dash_time_remaining: float = 0.0
var dash_hit_targets: Array[Node] = []

func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	# Delay emitting the signal until the next frame to ensure GameEvents and UI are ready
	call_deferred("_emit_initial_health")

func _emit_initial_health() -> void:
	GameEvents.player_health_changed.emit(current_health, max_health)

func take_damage(amount: int) -> void:
	current_health -= amount
	GameEvents.player_health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()

func die() -> void:
	GameEvents.player_died.emit()
	get_tree().call_deferred("reload_current_scene")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_just_pressed("use_card") and not _card_hand.is_empty():
		_use_card()

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var horizontal_vel := Vector3(velocity.x, 0.0, velocity.z)
	var target_vel := direction * speed

	if direction:
		horizontal_vel = horizontal_vel.move_toward(target_vel, acceleration * delta)
	else:
		horizontal_vel = horizontal_vel.move_toward(Vector3.ZERO, deceleration * delta)

	velocity.x = horizontal_vel.x
	velocity.z = horizontal_vel.z

	var pre_dash_vel := velocity
	move_and_slide()

	if dash_time_remaining > 0.0:
		dash_time_remaining -= delta
		var hit_enemy := false
		for i in get_slide_collision_count():
			var coll := get_slide_collision(i)
			var collider := coll.get_collider()
			if collider and collider.has_method("take_damage") and collider not in dash_hit_targets:
				dash_hit_targets.append(collider)
				collider.take_damage(100)
				hit_enemy = true
				if melee_hitbox and melee_hitbox.has_method("spawn_hit_spark"):
					melee_hitbox.spawn_hit_spark(coll.get_position(), coll.get_normal())
				# Add exception so we pass right through if it doesn't instantly vanish
				add_collision_exception_with(collider)

		if hit_enemy:
			# Restore momentum so the player punches right through the enemy instead of being stopped
			velocity = pre_dash_vel

func update_rotation(rotation_input: Vector3) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

# ── Card abilities ──────────────────────────────────────────────────────────

func _use_card() -> void:
	var type: CardType.Type = _card_hand.pop_front()

	match type:
		CardType.Type.ELEVATE:
			_do_elevate()
		CardType.Type.GODSPEED:
			_do_godspeed()
		CardType.Type.FIREBALL:
			_do_fireball()

	GameEvents.card_hand_changed.emit(_card_hand.duplicate())

func _do_elevate() -> void:
	# Straight upward burst — overrides any downward momentum
	velocity.y = elevate_velocity

func _do_godspeed() -> void:
	# Horizontal dash in the direction the character is FACING (no vertical)
	var forward := -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	velocity.x = forward.x * godspeed_velocity
	velocity.z = forward.z * godspeed_velocity
	# Tiny upward nudge so ground friction doesn't immediately kill the dash
	if is_on_floor():
		velocity.y = 1.5

	dash_time_remaining = 0.5
	dash_hit_targets.clear()

func _do_fireball() -> void:
	# Full 3D dash toward wherever the crosshair is pointing
	var cam := get_viewport().get_camera_3d()
	if cam:
		var aim_dir := -cam.global_transform.basis.z
		velocity = aim_dir.normalized() * fireball_velocity

	dash_time_remaining = 0.5
	dash_hit_targets.clear()

# ── Card inventory ──────────────────────────────────────────────────────────

## Called by CardPickup. Discards the oldest card if the hand is full.
func add_card(type: CardType.Type) -> bool:
	if _card_hand.size() >= max_hand_size:
		_card_hand.pop_front()
	_card_hand.append(type)
	GameEvents.card_hand_changed.emit(_card_hand.duplicate())
	return true

func get_hand() -> Array:
	return _card_hand.duplicate()

func get_card_count() -> int:
	return _card_hand.size()
