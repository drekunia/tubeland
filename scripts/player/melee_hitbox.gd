class_name MeleeHitbox extends ShapeCast3D

@export var melee_damage: int = 50
@export var melee_cooldown: float = 0.2

@export var player_controller: PlayerController
@export var melee_cast: ShapeCast3D
var can_melee: bool = true

func perform_melee():
	if not can_melee:
		return

	can_melee = false

	melee_cast.force_shapecast_update()

	if melee_cast.is_colliding():
		for i in melee_cast.get_collision_count():
			var target = melee_cast.get_collider(i)

			if target.has_method("take_damage"):
				target.take_damage(melee_damage)

	await get_tree().create_timer(melee_cooldown).timeout
	can_melee = true
