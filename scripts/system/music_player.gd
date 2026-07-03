extends Node

var audio_player: AudioStreamPlayer
var game_music = preload("res://assets/audio/music/Break My Heart.ogg")

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = game_music
	audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	audio_player.bus = "Music"
	audio_player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM

func play_game_music():
	if not audio_player.playing:
		audio_player.play()

func stop_music():
	if audio_player.playing:
		audio_player.stop()
