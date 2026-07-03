extends Control

@onready var main_vbox = $MainVBox
@onready var settings_vbox = $SettingsVBox

@onready var volume_slider = $SettingsVBox/VolumeHBox/VolumeSlider
@onready var sens_slider = $SettingsVBox/SensHBox/SensSlider

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_setup_slider_theme(volume_slider)
	_setup_slider_theme(sens_slider)

func _setup_slider_theme(slider: HSlider):
	var grad = Gradient.new()
	grad.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	grad.offsets = PackedFloat32Array([0.0, 0.85])
	grad.colors = PackedColorArray([Color.WHITE, Color.TRANSPARENT])
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 20
	tex.height = 20
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	slider.add_theme_icon_override("grabber", tex)
	slider.add_theme_icon_override("grabber_highlight", tex)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()
		# Prevent other nodes from handling this
		get_viewport().set_input_as_handled()

func pause_game():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	show_main()

func resume_game():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()

func show_main():
	main_vbox.show()
	settings_vbox.hide()

func show_settings():
	volume_slider.value = GlobalSettings.master_volume
	sens_slider.value = GlobalSettings.mouse_sensitivity
	main_vbox.hide()
	settings_vbox.show()

func _on_resume_button_pressed():
	resume_game()

func _on_restart_button_pressed():
	resume_game()
	# Reset timer and stats
	GameEvents.start_run()
	get_tree().reload_current_scene()

func _on_settings_button_pressed():
	show_settings()

func _on_exit_button_pressed():
	resume_game()
	GameEvents.is_run_active = false
	get_tree().change_scene_to_file("res://scenes/system/main_menu.tscn")

func _on_settings_back_button_pressed():
	GlobalSettings.save_settings()
	show_main()

func _on_volume_slider_value_changed(value):
	GlobalSettings.master_volume = value
	GlobalSettings.apply_settings()

func _on_sens_slider_value_changed(value):
	GlobalSettings.mouse_sensitivity = value
