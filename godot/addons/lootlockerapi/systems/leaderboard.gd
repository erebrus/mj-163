extends "res://addons/lootlockerapi/systems/base_system.gd"

const LIST_URL = "https://api.lootlocker.io/game/leaderboards/%s/list?count=%s&after=%s"
const UPLOAD_SCORE_URL = "https://api.lootlocker.io/game/leaderboards/%s/submit"
const GET_SCORE_URL = "https://api.lootlocker.io/game/leaderboards/%s/member/%s"

func list(leaderboard_key: String, count: int = 10, offset: int = 0) -> Array:
	print("Getting leaderboard %s, %s-%s" % [leaderboard_key, offset, offset + count])
	
	var url = LIST_URL % [leaderboard_key, count, offset]
	var data = await _request(url, HTTPClient.METHOD_GET)
	
	if data != null and "items" in data and data.items != null:
		return data.items
	
	push_error("Could not get items from leaderboard")
	return Array()
	

func upload_player_score(leaderboard_key: String, score: int) -> Variant:
	print("Submitting player score: %s to leaderboard %s" % [score, leaderboard_key])
	
	var request_data = { "score": str(score) }
	
	var url = UPLOAD_SCORE_URL % [leaderboard_key]
	var data = await _request(url, HTTPClient.METHOD_POST, request_data)
	
	print(data)
	return data
	

func get_player_score(leaderboard_key: String) -> Variant:
	print("Getting player score")
	
	var session = await authentication.get_session()
	if session == null or session.player_id == 0:
		return null
	
	var url = GET_SCORE_URL % [leaderboard_key, session.player_id]
	var data = await _request(url, HTTPClient.METHOD_GET)
	print(data)
	if data.rank == 0:
		return null
	return data
	
