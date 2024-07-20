@tool
class_name DessertSprite extends Sprite2D

@export var dessert_type: Types.DessertType:
	set(value):
		dessert_type = value
		_setup()

 
func _ready():
	_setup()
	

func _setup():
	texture = Types.DESSERT_TEXTURES[dessert_type]
