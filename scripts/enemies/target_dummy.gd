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
			is_aggro = true
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
