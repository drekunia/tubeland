extends Area3D

func _ready() -> void:
	add_to_group("checkpoint")
	body_entered.connect(_on_body_entered)
	
	var pos2d = Vector2(global_position.x, global_position.z)
	var is_touched = false
	for cp in GameEvents.touched_checkpoints:
		if cp.distance_to(pos2d) < 2.0:
			is_touched = true
			break
			
	if is_touched:
		var godray = get_node_or_null("../GodRay")
		if godray:
			godray.hide()
	
	if GameEvents.has_checkpoint:
		var scene_root = get_tree().current_scene
		if scene_root and scene_root.name != "LevelTwo":
			# Use meta to ensure we only queue the spawn once per scene load
			if not scene_root.has_meta("spawning_level_two") and not scene_root.has_node("LevelTwo"):
				scene_root.set_meta("spawning_level_two", true)
				
				var level_two_scene = load("res://scenes/environments/level_two.tscn")
				var level_two = level_two_scene.instantiate()
				level_two.name = "LevelTwo"
				
				var final_pos = Vector3(0, -5, -95)
				
				if not GameEvents.has_animated_level_two:
					level_two.position = Vector3(0, -19, -95)
					scene_root.call_deferred("add_child", level_two)
					call_deferred("_animate_level", level_two, final_pos)
					GameEvents.has_animated_level_two = true
				else:
					level_two.position = final_pos
					scene_root.call_deferred("add_child", level_two)

	if GameEvents.touched_checkpoints.size() >= 2:
		var scene_root_3 = get_tree().current_scene
		if scene_root_3 and scene_root_3.name != "LevelThree":
			if not scene_root_3.has_meta("spawning_level_three") and not scene_root_3.has_node("LevelThree"):
				scene_root_3.set_meta("spawning_level_three", true)
				
				var level_three_scene = load("res://scenes/environments/level_three.tscn")
				var level_three = level_three_scene.instantiate()
				level_three.name = "LevelThree"
				
				var final_pos = Vector3(0, -5, -95)
				
				if not GameEvents.has_animated_level_three:
					level_three.position = Vector3(0, -19, -95)
					scene_root_3.call_deferred("add_child", level_three)
					call_deferred("_animate_level", level_three, final_pos)
					GameEvents.has_animated_level_three = true
				else:
					level_three.position = final_pos
					scene_root_3.call_deferred("add_child", level_three)

	if GameEvents.touched_checkpoints.size() >= 3:
		var scene_root_4 = get_tree().current_scene
		if scene_root_4 and scene_root_4.name != "LevelFour":
			if not scene_root_4.has_meta("spawning_level_four") and not scene_root_4.has_node("LevelFour"):
				scene_root_4.set_meta("spawning_level_four", true)
				
				var level_four_scene = load("res://scenes/environments/level_four.tscn")
				var level_four = level_four_scene.instantiate()
				level_four.name = "LevelFour"
				
				var final_pos = Vector3(0, -5, -95)
				
				if not GameEvents.has_animated_level_four:
					level_four.position = Vector3(0, -19, -95)
					scene_root_4.call_deferred("add_child", level_four)
					call_deferred("_animate_level", level_four, final_pos)
					GameEvents.has_animated_level_four = true
				else:
					level_four.position = final_pos
					scene_root_4.call_deferred("add_child", level_four)

	if GameEvents.touched_checkpoints.size() >= 4:
		var scene_root_5 = get_tree().current_scene
		if scene_root_5 and scene_root_5.name != "LevelFive":
			if not scene_root_5.has_meta("spawning_level_five") and not scene_root_5.has_node("LevelFive"):
				scene_root_5.set_meta("spawning_level_five", true)
				
				var level_five_scene = load("res://scenes/environments/level_five.tscn")
				var level_five = level_five_scene.instantiate()
				level_five.name = "LevelFive"
				
				var final_pos = Vector3(0, -5, -95)
				
				if not GameEvents.has_animated_level_five:
					level_five.position = Vector3(0, -19, -95)
					scene_root_5.call_deferred("add_child", level_five)
					call_deferred("_animate_level", level_five, final_pos)
					GameEvents.has_animated_level_five = true
				else:
					level_five.position = final_pos
					scene_root_5.call_deferred("add_child", level_five)
func _animate_level(level_node: Node3D, final_pos: Vector3) -> void:
	var rigid_bodies = level_node.find_children("*", "RigidBody3D", true)
	for rb in rigid_bodies:
		rb.freeze = true

	var tween = get_tree().create_tween()
	tween.tween_property(level_node, "global_position", final_pos, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
		
	tween.tween_callback(func():
		for rb in rigid_bodies:
			if is_instance_valid(rb):
				rb.freeze = false
	)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if "time_alive" in body and body.time_alive < 0.1:
			return
			
		var current_pos = Vector2(global_position.x, global_position.z)
		var is_already_touched = false
		for cp in GameEvents.touched_checkpoints:
			if cp.distance_to(current_pos) < 2.0:
				is_already_touched = true
				break
				
		if is_already_touched:
			if "current_health" in body:
				GameEvents.saved_health = body.current_health
		else:
			GameEvents.set_checkpoint(global_position)
			var godray = get_node_or_null("../GodRay")
			if godray:
				godray.hide()
			
			if body.has_method("restore_health"):
				body.restore_health()
			
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
