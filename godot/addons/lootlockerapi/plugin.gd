@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("LootLocker", "res://addons/lootlockerapi/lootlocker.gd")
	_add_custom_project_setting("lootlocker/game_api_key", "", TYPE_STRING, PROPERTY_HINT_NONE, "")
	_add_custom_project_setting("lootlocker/game_version", "0.0.0.1", TYPE_STRING, PROPERTY_HINT_NONE, "")
	_add_custom_project_setting("lootlocker/player_identifier_storage", "None", TYPE_STRING, PROPERTY_HINT_ENUM, "None,UserData")


func _exit_tree():
	remove_autoload_singleton("LootLocker")
	

func _add_custom_project_setting(setting_name: String, default_value, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:
	if ProjectSettings.has_setting(setting_name): return

	var setting_info: Dictionary = {
		"name": setting_name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	}

	ProjectSettings.set_setting(setting_name, default_value)
	ProjectSettings.add_property_info(setting_info)
	ProjectSettings.set_initial_value(setting_name, default_value)
