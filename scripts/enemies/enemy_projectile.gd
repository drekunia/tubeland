class_name EnemyProjectile extends Area3D

@export var speed: float = 10.0
@export var damage: int = 1
@export var lifetime: float = 5.0

var _lifetime_timer: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move forward locally
	global_position += -global_transform.basis.z * speed * delta

	_lifetime_timer += delta
	if _lifetime_timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	# Ignore the enemy that shot it (and other enemies)
	if body is TargetDummy:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)

	# Destroy projectile on impact with anything else
	queue_free()

func take_damage(_amount: int) -> void:
	queue_free()
