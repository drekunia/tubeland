extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if GameEvents.has_checkpoint and GameEvents.current_checkpoint_position.is_equal_approx(global_position):
			if body.has_method("restore_health"):
				body.restore_health()
			return
			
		GameEvents.set_checkpoint(global_position)
		if body.has_method("restore_health"):
			body.restore_health()
			
		# Reload scene to reset all enemies, as requested
		get_tree().call_deferred("reload_current_scene")
