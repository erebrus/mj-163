@tool
class_name DessertSprite extends Sprite2D

@export var dessert_type: Types.DessertType:
	set(value):
		dessert_type = value
		_setup()

@export var flavour: Types.Flavour:
	set(value):
		flavour = value
		_setup()
 
func _ready():
	_setup()
	

func _setup():
	frame_coords = Vector2i(dessert_type, flavour)
