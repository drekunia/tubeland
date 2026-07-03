extends Control

@onready var time_label = $TimeLabel

func _process(_delta):
	if GameEvents.is_run_active:
		var current_time = GameEvents.get_current_run_time()
		time_label.text = "%.2f" % current_time
	else:
		var last_time = GameEvents.last_run_time
		if last_time > 0:
			time_label.text = "%.2f" % last_time
