class_name DessertStand extends Area2D

@export var cooldown = 5.0

var dessert_type: Types.DessertType
var flavour: Types.Flavour
var has_dessert: bool = false

@onready var sprite: DessertSprite = $DessertSprite


func _ready() -> void:
	_spawn_dessert()
	

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
	_spawn_dessert()
	

func _spawn_dessert() -> void:
	dessert_type = Types.DessertType.values().pick_random()
	flavour = Types.Flavour.values().pick_random()
	
	has_dessert = true
	sprite.dessert_type = dessert_type
	sprite.flavour = flavour
	sprite.visible = true
	
