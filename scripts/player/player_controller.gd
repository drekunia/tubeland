class_name PlayerController extends CharacterBody3D

@export var melee_hitbox : ShapeCast3D
@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 35.0
@export var deceleration: float = 20.0

## How hard you're launched upward when consuming an Elevate card
@export var elevate_velocity: float = 8.0
## Max number of Elevate cards the player can hold
@export var max_cards: int = 3

var _card_count: int = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Normal ground jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Right-click = consume one Elevate card for an air boost
	if Input.is_action_just_pressed("use_card") and _card_count > 0:
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

	move_and_slide()

func update_rotation(rotation_input: Vector3) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

func _use_card() -> void:
	_card_count -= 1
	velocity.y = elevate_velocity
	GameEvents.cards_changed.emit(_card_count, max_cards)

## Called by DoubleJumpPowerup when the player walks over it
func add_card(amount: int = 1) -> void:
	_card_count = mini(_card_count + amount, max_cards)
	GameEvents.cards_changed.emit(_card_count, max_cards)

func get_card_count() -> int:
	return _card_count
