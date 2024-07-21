class_name DessertStand extends Area2D

@export var cooldown = 4.0

var dessert_type: Types.DessertType
var flavour: Types.Flavour
var has_dessert: bool = false

@onready var sprite: DessertSprite = $DessertSprite


	

func _input(event: InputEvent) -> void:
	if not has_dessert:
		return
	
	if event.is_action_pressed("reload"):
		for area in get_overlapping_areas():
			if area.owner is Grandma:
				_reload(area.owner)
	

func _reload(grandma: Grandma) -> void:
	grandma.reload(dessert_type, flavour)
	has_dessert = false
	sprite.visible = false
	await get_tree().create_timer(cooldown).timeout
	Events.dessert_spawn_requested.emit(self)
	#_spawn_dessert()
	

func spawn_dessert(_dessert_type:Types.DessertType, _flavour:Types.Flavour) -> void:
	dessert_type = _dessert_type
	flavour = _flavour
	
	has_dessert = true
	sprite.dessert_type = dessert_type
	sprite.flavour = flavour
	sprite.visible = true
	
