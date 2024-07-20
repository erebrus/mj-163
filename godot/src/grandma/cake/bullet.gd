extends Area2D

@export var start_speed: float = 500
@export var dessert_type: Types.DessertType
@export var flavour: Types.Flavour


var velocity: Vector2
var eaten:= false

@onready var sprite: DessertSprite = $DessertSprite


func _physics_process(delta: float) -> void:
	position += velocity * delta
	

func shoot(_dessert_type: Types.DessertType, _flavour:Types.Flavour, angle: float) -> void:
	dessert_type = _dessert_type
	flavour = _flavour
	sprite.dessert_type = dessert_type
	sprite.flavour = flavour
	velocity = Vector2(start_speed, 0).rotated(angle - PI/2)
	visible = true
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	

func _on_body_entered(body: Node2D) -> void:
	if eaten:
		return
	
	if body.is_in_group("children") and body.accepts_cake():
		eaten = true
		body.feed(dessert_type, flavour)
		call_deferred("queue_free")
