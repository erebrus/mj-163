extends Control

const MIN_MARGIN :=10.0
const MAX_MARGIN :=350.0

const TEXTURES= [
	preload("res://assets/gfx/ui-elements/rage.png"),
	preload("res://assets/gfx/ui-elements/upset.png"),
	preload("res://assets/gfx/ui-elements/neutral.png"),
	preload("res://assets/gfx/ui-elements/happy.png")
]

@export var max_happiness := 100
@onready var icon: TextureRect = $HBoxContainer/Icon

func _ready() -> void:
	Events.happiness_changed.connect(set_happiness)

func set_happiness(value:float):
	var margin_value:float = MIN_MARGIN + (MAX_MARGIN-MIN_MARGIN)* (value/100.0)
	$HBoxContainer/Meter/HBoxContainer/PointerMargin.set("theme_override_constants/margin_left", margin_value )
	icon.texture = get_icon_for_happiness(value)
	
func get_icon_for_happiness(value:float)->Texture:
	if value < max_happiness/4.0:
		return TEXTURES[0]
	elif value < max_happiness/2.0:
		return TEXTURES[1]
	elif value < 3*max_happiness/4.0:
		return TEXTURES[2]
	else:
		return TEXTURES[3]
	
