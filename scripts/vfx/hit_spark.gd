extends GPUParticles3D

func _ready() -> void:
	# Ensure it starts emitting the moment it spawns
	emitting = true

	# Wait for the lifetime to end, then delete itself
	await get_tree().create_timer(lifetime).timeout
	queue_free()
