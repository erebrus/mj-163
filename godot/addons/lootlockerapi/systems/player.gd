extends "res://addons/lootlockerapi/systems/base_system.gd"

const UPDATE_NAME_URL = "https://api.lootlocker.io/game/player/name"
const GET_NAME_URL = "https://api.lootlocker.io/game/player/name"


func set_name(name: String) -> Variant:
	print("Updating player name to: %s" % [name])
	
	var request_data = { "name": str(name) }
	
	var data = await _request(UPDATE_NAME_URL, HTTPClient.METHOD_PATCH, request_data)
	print(data)
	
	return data
	

func get_name() -> String:
	print("Getting player name")
	
	var data = await _request(GET_NAME_URL, HTTPClient.METHOD_GET)
	print(data)
	
	return data.name
	
