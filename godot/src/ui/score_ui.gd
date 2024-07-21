extends TextureRect

@export var flash_color:Color=Color.AQUAMARINE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.score_changed.connect(_on_score_changed)


func _on_score_changed(score, flash):
	$Label.text = "%d" % [score]
	if flash:
		var original_color=$Label.get("theme_override_colors/font_color")
		var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property($Label,"theme_override_colors/font_color", flash_color, .5)
		tween.tween_property($Label,"theme_override_colors/font_color", original_color, .5)
	
