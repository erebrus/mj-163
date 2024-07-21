extends MarginContainer

const LEADERBOARD_KEY = "mj163"
const ROW = preload("res://src/gui/leaderboard_row.tscn")


@export var rows = 6

var is_highscore: bool
var is_top: bool = false
var old_player_name: String

@onready var leaderboard: Container = %LeaderboardContents


func update():
	var items = await LootLocker.leaderboard.list(LEADERBOARD_KEY, rows, 0)
	Logger.info("Obtained items from lootlocker %s" % [items])
	
	var player = await LootLocker.leaderboard.get_player_score(LEADERBOARD_KEY)
	
	if player.rank > rows:
		items = items.slice(0, 5) + [player]
	
	if items.is_empty():
		return
	
	for child in leaderboard.get_children():
		child.hide()
		child.queue_free()
	
	for item in items:
		var row = ROW.instantiate()
		row.setup(item)
		leaderboard.add_child(row)
	

func submit_score(score: int):
	Globals.in_game = false
	var previous = await LootLocker.leaderboard.get_player_score(LEADERBOARD_KEY)
	
	is_highscore = previous == null or previous.score < score
	
	if is_highscore:
		await LootLocker.leaderboard.upload_player_score(LEADERBOARD_KEY, score)
		previous = await LootLocker.leaderboard.get_player_score(LEADERBOARD_KEY)
	
	await update()
	Events.on_clear_players_requested.emit()
	update_granny_text(previous)
	show()
	

func submit_name(player_name: String):
	await LootLocker.player.set_name(player_name)
	update()


func update_granny_text(player):
	var has_name = not player.player.name.is_empty()
	
	var text: String
	
	if is_highscore:
		text = "Well done, new highscore! "
		if is_top:
			text += "And in the top 6! "
		else:
			text += "Your new ranking is %s. " % player.rank
	else:
		text = "I know you can do better, you were number %s! " % player.rank
	if is_top:
		text += " "
	
	if not has_name:
		text += "\nGo on, tell us your name."
	
	%GrannyLabel.text = text
	

func _on_retry_button_pressed():
	Globals.in_game = true
	get_tree().reload_current_scene()


func _on_line_edit_text_submitted(new_text):
	submit_name(new_text)


func _on_submit_button_pressed():
	submit_name(%PlayerName.text)
