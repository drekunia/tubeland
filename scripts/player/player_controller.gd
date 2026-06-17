class_name PlayerController extends CharacterBody3D

@export var melee_hitbox : ShapeCast3D
@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 35.0
@export var deceleration: float = 20.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

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

func _unhandled_input(event: InputEvent) -> void:
	# Check if the exact action we created in the Input Map was just pressed
	if event.is_action_pressed("attack"):
		melee_hitbox.perform_melee()
