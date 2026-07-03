extends Node

var master_volume: float = 10.0 # 0.0 to 10.0
var music_volume: float = 10.0 # 0.0 to 10.0
var sfx_volume: float = 10.0 # 0.0 to 10.0
var mouse_sensitivity: float = 5.0
var best_time: float = 0.0 # 0.0 means no best time yet

const SAVE_PATH = "user://settings.cfg"

func _ready():
	load_settings()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("Audio", "master_volume", master_volume)
	config.set_value("Audio", "music_volume", music_volume)
	config.set_value("Audio", "sfx_volume", sfx_volume)
	config.set_value("Controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("Stats", "best_time", best_time)
	config.save(SAVE_PATH)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		master_volume = config.get_value("Audio", "master_volume", 10.0)
		music_volume = config.get_value("Audio", "music_volume", 10.0)
		sfx_volume = config.get_value("Audio", "sfx_volume", 10.0)
		mouse_sensitivity = config.get_value("Controls", "mouse_sensitivity", 5.0)
		best_time = config.get_value("Stats", "best_time", 0.0)

	apply_settings()

func apply_settings():
	# Ensure Music and SFX buses exist
	var music_idx = AudioServer.get_bus_index("Music")
	if music_idx == -1:
		AudioServer.add_bus()
		music_idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(music_idx, "Music")
		AudioServer.set_bus_send(music_idx, "Master")

	var sfx_idx = AudioServer.get_bus_index("SFX")
	if sfx_idx == -1:
		AudioServer.add_bus()
		sfx_idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(sfx_idx, "SFX")
		AudioServer.set_bus_send(sfx_idx, "Master")

	var master_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_idx, linear_to_db(master_volume / 10.0))
	AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_volume / 10.0) - 6.0)
	AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx_volume / 10.0) + 9.0)
