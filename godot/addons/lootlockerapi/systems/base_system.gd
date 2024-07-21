extends RefCounted

const Authentication = preload("res://addons/lootlockerapi/authentication/authentication.gd")

var http: Node
var authentication: Authentication

func _init(_http: Node, _authentication: Authentication) -> void:
	http = _http
	authentication = _authentication
	

func _request(url: String, method: int, body: Variant = null) -> Variant:
	var session = await authentication.get_session()
	if session.token.is_empty():
		return null
	
	var headers = ["Content-Type: application/json", "x-session-token:"+session.token]
	var content = ""
	if body != null:
		content = JSON.stringify(body)
	
	var result = await http.request(url, headers, method, content)
	# todo: handle session expired / not logged in
	return result
