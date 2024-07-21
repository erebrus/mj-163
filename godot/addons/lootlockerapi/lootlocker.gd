extends Node

const HttpRequestHelper = preload("res://addons/lootlockerapi/http_request_helper.gd")
const Authentication = preload("res://addons/lootlockerapi/authentication/authentication.gd")
const Player = preload("res://addons/lootlockerapi/systems/player.gd")
const Leaderboard = preload("res://addons/lootlockerapi/systems/leaderboard.gd")

var game_api_key: String:
	set(value):
		game_api_key = value
		_setup()
	

var  game_version: String = "0.0.0.1":
	set(value):
		game_version = value
		_setup()
	

var player_identifier_storage: Authentication.PlayerIdentifierStorage
	

var http_request: HttpRequestHelper = HttpRequestHelper.new()
var authentication: Authentication
var player: Player
var leaderboard: Leaderboard


func _init() -> void:
	if ProjectSettings.has_setting("lootlocker/game_api_key"):
		var setting = ProjectSettings.get_setting("lootlocker/game_api_key")
		if not setting.is_empty():
			game_api_key = setting
	
	if game_api_key.is_empty():
		game_api_key = OS.get_environment("LOOTLOCKER_API_KEY")
	
	if ProjectSettings.has_setting("lootlocker/game_version"):
		game_version = ProjectSettings.get_setting("lootlocker/game_version")
	
	if ProjectSettings.has_setting("lootlocker/player_identifier_storage"):
		var setting = ProjectSettings.get_setting("lootlocker/player_identifier_storage")
		player_identifier_storage = Authentication.PlayerIdentifierStorage[setting]
	

func _ready() -> void:
	add_child(http_request)
	_setup()
	

func _setup() -> void:
	if not is_inside_tree():
		return
	
	authentication = Authentication.new(http_request, game_api_key, game_version)
	authentication.player_identifier_storage = player_identifier_storage
	
	player = Player.new(http_request, authentication)
	leaderboard = Leaderboard.new(http_request, authentication)
	

