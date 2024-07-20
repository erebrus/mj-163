extends Node


var master_volume:float = 100
var music_volume:float = 100
var sfx_volume:float = 100

const GameDataPath = "user://conf.cfg"
var config:ConfigFile

var debug_build := false




#@onready var menu_music: AudioStreamPlayer = $menu_music
#@onready var game_music: AudioStreamPlayer = $game_music

func _ready():
	_init_logger()

	
#func start_game():
	#get_tree().change_scene_to_file("res://src/game.tscn")
#
#func win_game():
	#get_tree().change_scene_to_file("res://src/win_screen.tscn")
	
func _init_logger():
	Logger.set_logger_level(Logger.LOG_LEVEL_INFO)
	Logger.set_logger_format(Logger.LOG_FORMAT_MORE)
	var console_appender:Appender = Logger.add_appender(ConsoleAppender.new())
	console_appender.logger_format=Logger.LOG_FORMAT_FULL
	console_appender.logger_level = Logger.LOG_LEVEL_DEBUG
	var file_appender:Appender = Logger.add_appender(FileAppender.new("res://debug.log"))
	file_appender.logger_format=Logger.LOG_FORMAT_FULL
	file_appender.logger_level = Logger.LOG_LEVEL_DEBUG
	Logger.info("Logger initialized.")


#func init_music():
	#%Music.stop()
	#%Music.volume_db=-60
	#%Music.play()
	#var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#tween.tween_property(%Music,"volume_db",0,2)
	

#func play_music(node:AudioStreamPlayer):
	#node.volume_db = 0
	#node.play()
	#
#func fade_music(node:AudioStreamPlayer, duration := 1):
	#var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#tween.tween_property(node,"volume_db",-20 , duration)
	#await tween.finished
	#node.stop()
	
	
