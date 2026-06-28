class_name TargetDummy extends RigidBody3D

@export var card_pickup_scene: PackedScene
@export var drop_card_type: CardType.Type = CardType.Type.ELEVATE

var health: int = 100

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
