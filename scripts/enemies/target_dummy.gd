class_name TargetDummy extends RigidBody3D

var health: int = 100

func take_damage(amount: int):
	health -= amount

	if health <= 0:
		die()

func die():
	queue_free()
