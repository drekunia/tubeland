class_name MeleeHitbox extends ShapeCast3D

@export var melee_damage: int = 50
@export var melee_cooldown: float = 0.5

@export var player_controller: PlayerController
@export var slash_visual: MeshInstance3D
@export var hit_spark_scene: PackedScene

var can_melee: bool = true


func _ready() -> void:
	collide_with_areas = true

	# Tell the Shapecast to NEVER collide with the player!
	if player_controller:
		add_exception(player_controller)
	else:
		print_debug("WARNING: player_controller is not assigned in the Inspector!")

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("attack"):
		perform_melee()

func perform_melee():
	if not can_melee:
		return

	can_melee = false

	var swing_sfx = AudioStreamPlayer.new()
	swing_sfx.stream = preload("res://assets/audio/sfx/melee_swing.wav")
	swing_sfx.bus = "SFX"
	get_tree().current_scene.add_child(swing_sfx)
	swing_sfx.play()
	swing_sfx.finished.connect(swing_sfx.queue_free)

	if slash_visual:
		var mat = slash_visual.get_active_material(0)

		if mat:
			slash_visual.rotation_degrees.z = randf_range(-30.0, 30.0)
			var random_flip = 1 if randi() % 2 == 0 else -1

			var random_x = randf_range(-0.5, 0.5)
			var random_y = randf_range(-0.35, 0.35)
			slash_visual.position = Vector3(random_x, random_y, -1.25)

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
		var hit_sfx = AudioStreamPlayer.new()
		hit_sfx.stream = preload("res://assets/audio/sfx/melee_hit.wav")
		hit_sfx.bus = "SFX"
		get_tree().current_scene.add_child(hit_sfx)
		hit_sfx.play()
		hit_sfx.finished.connect(hit_sfx.queue_free)

		var hit_point = get_collision_point(0)
		var hit_normal = get_collision_normal(0)

		spawn_hit_spark(hit_point, hit_normal)

		for i in get_collision_count():
			var target = get_collider(i)
			if target.has_method("take_damage"):
				target.take_damage(melee_damage)

	await get_tree().create_timer(melee_cooldown).timeout
	can_melee = true

func spawn_hit_spark(pos: Vector3, normal: Vector3) -> void:
	if not hit_spark_scene:
		return

	var spark = hit_spark_scene.instantiate()
	get_tree().current_scene.add_child(spark)

	# Move it to the exact point the sword hit
	spark.global_position = pos - (normal * 0.2)

	# --- ROTATION LOGIC ---
	# Define our default "Up" direction
	var safe_up = Vector3.UP

	# If the wall normal is pointing almost perfectly straight up or straight down...
	# We temporarily change the "Up" reference to Vector3.RIGHT to prevent the math from breaking!
	if abs(normal.y) > 0.99:
		safe_up = Vector3.RIGHT

	# Now we can safely look away from the wall on ANY surface (walls, floors, ceilings)
	spark.look_at(pos + normal, safe_up)
	# ----------------------
