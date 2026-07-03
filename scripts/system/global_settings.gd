extends Node

var master_volume: float = 10.0 # 0.0 to 10.0
var mouse_sensitivity: float = 5.0
var best_time: float = 0.0 # 0.0 means no best time yet

const SAVE_PATH = "user://settings.cfg"

func _ready():
	load_settings()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("Audio", "master_volume", master_volume)
	config.set_value("Controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("Stats", "best_time", best_time)
	config.save(SAVE_PATH)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		master_volume = config.get_value("Audio", "master_volume", 10.0)
		mouse_sensitivity = config.get_value("Controls", "mouse_sensitivity", 5.0)
		best_time = config.get_value("Stats", "best_time", 0.0)
	
	apply_settings()

func apply_settings():
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(master_volume / 10.0))
