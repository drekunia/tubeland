class_name MeleeHitbox extends ShapeCast3D

@export var melee_damage: int = 50
@export var melee_cooldown: float = 0.5

@export var player_controller: PlayerController
@export var slash_visual: MeshInstance3D

var can_melee: bool = true

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("attack"):
		perform_melee()

func perform_melee():
	if not can_melee:
		return

	can_melee = false

	if slash_visual:
		var mat = slash_visual.get_active_material(0)

		if mat:
			slash_visual.rotation_degrees.z = randf_range(-30.0, 30.0)
			var random_flip = 1 if randi() % 2 == 0 else -1

			var random_x = randf_range(-0.5, 0.5)
			var random_y = randf_range(-0.4, 0.4)
			slash_visual.position = Vector3(random_x, random_y, -1.5)

			slash_visual.scale = Vector3(2.0 * random_flip, 0.05, 0.5)
			mat.set_shader_parameter("fade_opacity", 1.0)

			var tween = create_tween()

			tween.tween_property(mat, "shader_parameter/fade_opacity", 0.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		else:
			print_debug("WARNING: slash_visual found, but it has no Material!")
	else:
		print_debug("WARNING: slash_visual is missing! Did you drag the node into the Inspector?")

	force_shapecast_update()

	if is_colliding():
		for i in get_collision_count():
			var target = get_collider(i)
			if target.has_method("take_damage"):
				target.take_damage(melee_damage)

	await get_tree().create_timer(melee_cooldown).timeout
	can_melee = true
