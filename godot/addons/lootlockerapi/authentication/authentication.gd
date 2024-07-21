extends RefCounted

const GUEST_AUTHENTICATION_URL = "https://api.lootlocker.io/game/v2/session/guest"

const PLAYER_IDENTIFIER_PATH = "user://LootLocker.data"

enum AuthMethod {
	GuestLogin
}

enum PlayerIdentifierStorage {
	None,
	UserData
}

var auth_method: AuthMethod = AuthMethod.GuestLogin

var player_identifier_storage: PlayerIdentifierStorage = PlayerIdentifierStorage.UserData:
	set(value):
		player_identifier_storage = value
		match player_identifier_storage:
			PlayerIdentifierStorage.None:
				_on_local_player_identifier_requested = func() : return null
				_on_local_player_identifier_obtained = func(x) : return
			PlayerIdentifierStorage.UserData:
				_on_local_player_identifier_requested = _get_local_player_identifier
				_on_local_player_identifier_obtained = _set_local_player_identifier
	

var _game_api_key: String
var _game_version: String
var _session: Session

var _http: Node

var _on_local_player_identifier_requested: Callable
var _on_local_player_identifier_obtained: Callable


func _init(http, game_api_key, game_version) -> void:
	_http = http
	_game_api_key = game_api_key
	_game_version = game_version
	

func login() -> String:
	match auth_method:
		AuthMethod.GuestLogin:
			await _guest_login()
	
	return _session.token
	

func get_session() -> Session:
	if _session == null or not _session.is_valid():
		await login()
	return _session
	

func _guest_login() -> void:
	var request_data = { 
		"game_key": _game_api_key, 
		"game_version": _game_version, 
	}
	
	var player_id = _on_local_player_identifier_requested.call()
	if player_id != null and not player_id.is_empty():
		request_data["player_identifier"] = player_id
	
	var headers = ["Content-Type: application/json"]
	
	print("Requesting guest player login:")
	print(request_data)
	
	var data = await _http.request(GUEST_AUTHENTICATION_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(request_data))
	print("Response:")
	print(data)
	
	_session = Session.new(data)
	
	if not _session.player_identifier.is_empty():
		_on_local_player_identifier_obtained.call(_session.player_identifier)
	

func _get_local_player_identifier() -> String:
	var file = FileAccess.open(PLAYER_IDENTIFIER_PATH, FileAccess.READ)
	if file != null:
		var player_id = file.get_as_text()
		file.close()
		return player_id
	return ""
	

func _set_local_player_identifier(player_id: String) -> void:
	var file = FileAccess.open(PLAYER_IDENTIFIER_PATH, FileAccess.WRITE)
	file.store_string(player_id)
	file.close()
	


class Session:
	var token: String
	var player_id: float
	var player_identifier: String
	
	func _init(data: Dictionary) -> void:
		if data.has("session_token"):
			token = data.session_token
		if data.has("player_id"):
			player_id = data.player_id
		if data.has("player_identifier"):
			player_identifier = data.player_identifier
		
	func is_valid() -> bool:
		return not token.is_empty()
