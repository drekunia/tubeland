extends Control

@onready var main_vbox = $MainVBox
@onready var settings_vbox = $SettingsVBox
@onready var quit_button = $MainVBox/QuitButton

@onready var volume_slider = $SettingsVBox/VolumeHBox/VolumeSlider
@onready var music_slider = $SettingsVBox/MusicHBox/MusicSlider
@onready var sfx_slider = $SettingsVBox/SFXHBox/SFXSlider
@onready var sens_slider = $SettingsVBox/SensHBox/SensSlider
@onready var best_time_label = $MainVBox/BestTimeLabel
@onready var last_time_label = $MainVBox/LastTimeLabel

func _ready():
	MusicPlayer.stop_music()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show_main()
	
	if OS.has_feature("web"):
		quit_button.hide()
	
	# Load settings to UI
	volume_slider.value = GlobalSettings.master_volume
	music_slider.value = GlobalSettings.music_volume
	sfx_slider.value = GlobalSettings.sfx_volume
	sens_slider.value = GlobalSettings.mouse_sensitivity
	_setup_slider_theme(volume_slider)
	_setup_slider_theme(music_slider)
	_setup_slider_theme(sfx_slider)
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
	
	# Update best time label
	if GlobalSettings.best_time > 0.0:
		best_time_label.text = "Best Time: %.2f s" % GlobalSettings.best_time
	else:
		best_time_label.text = "Best Time: --"

	# Update last time label
	if GameEvents.last_run_time > 0.0:
		last_time_label.text = "Last Time: %.2f s" % GameEvents.last_run_time
		last_time_label.show()
	else:
		last_time_label.hide()

func show_main():
	main_vbox.show()
	settings_vbox.hide()

func show_settings():
	main_vbox.hide()
	settings_vbox.show()

func _on_start_button_pressed():
	MusicPlayer.play_game_music()
	GameEvents.start_run()
	get_tree().change_scene_to_file("res://scenes/environments/level_one.tscn")

func _on_settings_button_pressed():
	show_settings()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_settings_back_button_pressed():
	GlobalSettings.save_settings()
	show_main()

func _on_volume_slider_value_changed(value):
	GlobalSettings.master_volume = value
	GlobalSettings.apply_settings()

func _on_music_slider_value_changed(value):
	GlobalSettings.music_volume = value
	GlobalSettings.apply_settings()

func _on_sfx_slider_value_changed(value):
	GlobalSettings.sfx_volume = value
	GlobalSettings.apply_settings()

func _on_sens_slider_value_changed(value):
	GlobalSettings.mouse_sensitivity = value
