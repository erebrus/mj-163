extends Node


var master_volume:float = 100
var music_volume:float = 100
var sfx_volume:float = 100

const GameDataPath = "user://conf.cfg"
var config:ConfigFile

var debug_build := false


var music_on:=true:
	set(v):
		music_on=v
		Logger.info("music %s" % [music_on])
		var sfx_index= AudioServer.get_bus_index("Music")
		AudioServer.set_bus_volume_db(sfx_index, -6 if music_on else -100)		
		#if not music_on:
			#menu_music.stop()
			#game_music.stop()
			
var sound_on:=true:
	set(v):
		sound_on = v
		Logger.info("sound %s" % [sound_on])
		var sfx_index= AudioServer.get_bus_index("Sound")
		AudioServer.set_bus_volume_db(sfx_index, 0 if sound_on else -100)

@onready var menu_music: AudioStreamPlayer = $menu_music
@onready var game_music: AudioStreamPlayer = $game_music

func _ready():
	_init_logger()
	fade_in_music(menu_music)

	
func start_game():
	fade_music(menu_music,1)
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://src/arena/arena.tscn")
	fade_in_music(game_music)
#
#func win_game():
	#get_tree().change_scene_to_file("res://src/win_screen.tscn")
	
func _init_logger():
	Logger.set_logger_level(Logger.LOG_LEVEL_INFO)
	Logger.set_logger_format(Logger.LOG_FORMAT_MORE)
	var console_appender:Appender = Logger.add_appender(ConsoleAppender.new())
	console_appender.logger_format=Logger.LOG_FORMAT_FULL
	console_appender.logger_level = Logger.LOG_LEVEL_INFO
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
	


func play_music(node:AudioStreamPlayer):
	if not node.playing:
		node.volume_db = 0
		node.play()

func fade_in_music(node:AudioStreamPlayer, duration := 1):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	node.volume_db=-20
	node.play()
	tween.tween_property(node,"volume_db",0 , duration)
	#await tween.finished
	
		#
func fade_music(node:AudioStreamPlayer, duration := 1):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node,"volume_db",-20 , duration)
	await tween.finished
	node.stop()
	
	
