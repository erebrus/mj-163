extends MarginContainer


func setup(item):
	var player_name: String = item.player.name
	if player_name.is_empty():
		player_name = "mystery player"
	%Rank.text = str(item.rank)
	%Name.text = player_name
	%Score.text = str(item.score)
