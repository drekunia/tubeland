extends Camera3D

@export var player_controller: CharacterBody3D
@export var camera_juice: bool = true

@export var speed_lines: GPUParticles3D
@export var speed_overlay: ColorRect

@export var speed_threshold: float = 2.5
@export var speedline_threshold: float = 4.5

@export var base_fov: float = 75.0
@export var max_fov: float = 80.0
@export var fov_change_speed: float = 10.0

@export var max_tilt: float = 2.5
@export var tilt_speed: float = 2.0


func _process(delta: float) -> void:
	var is_speeding = false

	if player_controller.velocity.length() > speedline_threshold:
		is_speeding = true

	if speed_lines:
		speed_lines.emitting = is_speeding

		if is_speeding and player_controller.velocity.length_squared() > 0.1:
			var vel_dir = player_controller.velocity.normalized()

			# Godot's look_at math breaks if you look perfectly straight up or down.
			# This protects against game crashes if you jump straight up or fall straight down.
			var up_dir = Vector3.UP
			if abs(vel_dir.y) > 0.99:
				up_dir = Vector3.RIGHT

			var target_basis = Basis.looking_at(vel_dir, up_dir)
			#speed_lines.global_transform.basis = speed_lines.global_transform.basis.slerp(target_basis, delta * 15.0)
			speed_lines.global_transform.basis = target_basis

	if speed_overlay and speed_overlay.material:
		# Get the current intensity from the shader
		var current_intensity = speed_overlay.material.get_shader_parameter("intensity")

		# Target is 1.0 (Full effect) if speeding, 0.0 (Invisible) if slow
		var target_intensity = 1.0 if is_speeding else 0.0

		# Smoothly fade the shader in and out
		var new_intensity = lerp(current_intensity, target_intensity, delta * 5.0)
		speed_overlay.material.set_shader_parameter("intensity", new_intensity)

	if not camera_juice or not player_controller:
		return

	var horizontal_speed = Vector2(player_controller.velocity.x, player_controller.velocity.z).length()

	var target_fov = base_fov
	var target_tilt = 0.0

	if horizontal_speed > speed_threshold:
		var speed_excess = horizontal_speed - speed_threshold
		target_fov = clamp(base_fov + (speed_excess * 2), base_fov, max_fov)

		var local_velocity = player_controller.transform.basis.inverse() * player_controller.velocity
		var right_dot = local_velocity.normalized().x
		target_tilt = right_dot * max_tilt * -1.0

	fov = lerp(fov, target_fov, delta * fov_change_speed)

	rotation_degrees.z = lerp(rotation_degrees.z, target_tilt, delta * tilt_speed)
