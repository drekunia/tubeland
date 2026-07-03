class_name TargetDummy extends RigidBody3D

@export var card_pickup_scene: PackedScene
@export var drop_card_type: CardType.Type = CardType.Type.ELEVATE
@export var enemy_projectile_scene: PackedScene = preload("res://scenes/enemies/enemy_projectile.tscn")
@export var fire_rate: float = 5.0
@export var aggro_radius: float = 10.0

var health: int = 100
@onready var fire_timer: float = fire_rate * randf_range(0.5, 1.5)
@onready var head: Node3D = $smiley

var shoot_intensity: float = 0.0
var visual_mat: ShaderMaterial

func _ready() -> void:
	if head:
		var mesh_instance = head.get_node("Smiley") as MeshInstance3D
		if mesh_instance:
			var mat = mesh_instance.get_active_material(0) as ShaderMaterial
			if mat:
				visual_mat = mat.duplicate() as ShaderMaterial
				mesh_instance.set_surface_override_material(0, visual_mat)

func _process(delta: float) -> void:
	if shoot_intensity > 0.0:
		shoot_intensity = move_toward(shoot_intensity, 0.0, delta * 3.0)
		if visual_mat:
			visual_mat.set_shader_parameter("shoot_intensity", shoot_intensity)

	var is_aggro = false
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var player = players[0]
		if global_position.distance_to(player.global_position) <= aggro_radius:
			var space_state = get_world_3d().direct_space_state
			var start_pos = global_position + Vector3(0, 1.5, 0)
			var end_pos = player.global_position + Vector3(0, 1.5, 0)
			var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
			query.exclude = [self.get_rid()]
			var result = space_state.intersect_ray(query)

			if result and result.collider == player:
				is_aggro = true

		if is_aggro:
			# Turn body to face the player (only rotating on the Y axis)
			var target_pos = player.global_position
			target_pos.y = global_position.y
			if global_position.distance_to(target_pos) > 0.1:
				var opposite_pos = global_position * 2.0 - target_pos
				look_at(opposite_pos, Vector3.UP)

			# Make the head tilt/aim fully at the player's camera level
			if head:
				var aim_target = player.global_position + Vector3(0, 1.5, 0)
				var opposite_aim = head.global_position * 2.0 - aim_target
				head.look_at(opposite_aim, Vector3.UP)

				# Prevent the enemy from leaning too far back when the player is close
				head.rotation.x = clampf(head.rotation.x, -0.25, 0.25)

	if is_aggro:
		fire_timer -= delta
		if fire_timer <= 0.0:
			fire_timer = fire_rate * randf_range(0.75, 1.25)
			_shoot_at_player()
	else:
		fire_timer = fire_rate * randf_range(0.75, 1.25)

func _shoot_at_player() -> void:
	if not enemy_projectile_scene:
		return

	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	var player = players[0]

	if global_position.distance_to(player.global_position) > aggro_radius:
		return

	var proj = enemy_projectile_scene.instantiate() as Node3D
	get_tree().current_scene.add_child(proj)

	# Play shoot sound
	var sfx = AudioStreamPlayer3D.new()
	sfx.stream = preload("res://assets/audio/sfx/enemy_shoot.wav")
	sfx.bus = "SFX"
	get_tree().current_scene.add_child(sfx)
	sfx.global_position = global_position
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

	# Spawn a bit above the dummy's base position
	proj.global_position = global_position + Vector3(0, 1.5, 0)

	# Aim at the player's center (assuming player origin is at feet or center, add an offset to aim at body)
	proj.look_at(player.global_position + Vector3(0, 1.5, 0), Vector3.UP)

	shoot_intensity = 1.0

func take_damage(amount: int):
	health -= amount

	if health <= 0:
		die()

func die():
	# Play die sound attached to scene root so it doesn't get cut off
	var sfx = AudioStreamPlayer3D.new()
	sfx.stream = preload("res://assets/audio/sfx/enemy_die.wav")
	sfx.bus = "SFX"
	get_tree().current_scene.add_child(sfx)
	sfx.global_position = global_position
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

	collision_layer = 0
	collision_mask = 0
	_drop_card()
	queue_free()

func _drop_card() -> void:
	if not card_pickup_scene:
		return

	var pickup := card_pickup_scene.instantiate() as CardPickup

	# Set card_type BEFORE add_child so _ready() → _apply_visuals() sees the right color.
	pickup.card_type = drop_card_type

	# add_child first (global_position needs the node inside the tree),
	# then position it above the enemy.
	get_tree().current_scene.add_child(pickup)
	pickup.global_position = global_position + Vector3(0, 0.75, 0)
