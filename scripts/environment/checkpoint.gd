extends Area3D

func _ready() -> void:
	add_to_group("checkpoint")
	body_entered.connect(_on_body_entered)
	if GameEvents.has_checkpoint:
		var level_two_scene = load("res://scenes/environments/level_two.tscn")
		var level_two = level_two_scene.instantiate()
		
		var final_pos = Vector3(0, -5, -95)
		level_two.global_position = Vector3(0, -19, -95)
		
		get_tree().current_scene.call_deferred("add_child", level_two)
		call_deferred("_animate_level_two", level_two, final_pos)

func _animate_level_two(level_node: Node3D, final_pos: Vector3) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(level_node, "global_position", final_pos, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if GameEvents.has_checkpoint and GameEvents.current_checkpoint_position.is_equal_approx(global_position):
			if body.has_method("restore_health"):
				body.restore_health()
			return
			
		GameEvents.set_checkpoint(global_position)
		if "_card_hand" in body:
			GameEvents.save_card_hand(body._card_hand)
			
		if body.has_method("restore_health"):
			body.restore_health()
			
		# Save the player's camera angle before reloading the scene
		if body.has_node("CameraController"):
			GameEvents.save_camera_euler(body.get_node("CameraController")._camera_euler)
			
		GameEvents.is_seamless_transition = true
		GameEvents.seamless_position = body.global_position
		GameEvents.seamless_velocity = body.velocity
			
		# Reload scene to reset all enemies, as requested
		get_tree().call_deferred("reload_current_scene")
