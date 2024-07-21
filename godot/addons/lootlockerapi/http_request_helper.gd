extends Node


func request(url: String, headers: Array, method: int, body: String = "") -> Variant:
	var request = HTTPRequest.new()
	add_child(request)
	
	request.request.call_deferred(url, headers, method, body)
	var result = await request.request_completed
	request.queue_free()
	
	return _parse_result.callv(result)
	

func _parse_result(result: int, status_code: int, headers: PackedStringArray, body: PackedByteArray) -> Variant:
	if result > 0:
		return _handle_error(result)
	if status_code < 200 or status_code >= 300:
		if body != null:
			return _handle_error_status_code(status_code, body.get_string_from_utf8())
		else:
			return _handle_error_status_code(status_code, "")
	
	if body != null:
		return _parse_json(body.get_string_from_utf8())
	else:
		return null
	

func _handle_error(result: int) -> Variant:
	var error: String
	match result:
		ERR_UNCONFIGURED:
			error = "HTTPRequest not in the node tree"
		ERR_BUSY:
			error = "HTTPRequest still busy with previous request"
		ERR_INVALID_PARAMETER:
			error = "Given string is not a valid URL format"
		ERR_CANT_CONNECT:
			error = "HTTPClient cannot connect to host"
		_:
			error = "Unknown"
	
	print("Error %s: %s" % [result, error])
	return null
	

func _handle_error_status_code(status_code: int, result: String) -> Variant:
	print("Invalid response [status code %s]: %s" % [status_code, result])
	return _parse_json(result)
	

func _parse_json(str: String) -> Variant:
	if str.is_empty():
		print("JSON Parse Error: Empty JSON string")
		return null
	
	var json = JSON.new()
	match json.parse(str):
		OK:
			return json.data
		_:
			print("JSON Parse Error: %s at line %s in \n %s" % [json.get_error_message(), json.get_error_line(), str])
			return null
