extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.in_game=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sound_button_toggled(toggled_on: bool) -> void:
	$sfx_button.play()
	Globals.sound_on=toggled_on


func _on_music_button_toggled(toggled_on: bool) -> void:
	$sfx_button.play()
	Globals.music_on=toggled_on


func _on_start_button_pressed() -> void:
	$sfx_button.play()
	Globals.start_game()
	
