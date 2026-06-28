class_name TargetDummy extends RigidBody3D

@export var double_jump_powerup_scene: PackedScene

var health: int = 100

func take_damage(amount: int):
	health -= amount

	if health <= 0:
		die()

func die():
	_drop_powerup()
	queue_free()

func _drop_powerup() -> void:
	if not double_jump_powerup_scene:
		return

	var powerup = double_jump_powerup_scene.instantiate()

	# Add to tree first (global_position requires being inside the scene tree),
	# then set position. The powerup's _initialized flag captures _base_y on
	# the first _process frame, so the hover origin will be correct.
	get_tree().current_scene.add_child(powerup)
	powerup.global_position = global_position + Vector3(0, 0.75, 0)
