class_name Grandma extends PathFollow2D


@export var speed:= 500

var moving :=false

var dessert_type:= Types.DessertType.Cupcake:
	set(value):
		dessert_type = value
		dessert_sprite.dessert_type = value

var flavour:= Types.Flavour.Chocolate:
	set(value):
		flavour = value
		dessert_sprite.flavour = value	
		
var current_ammo := 0:
	set(value):
		current_ammo = value
		dessert_sprite.visible = _has_ammo()
		ammo_label.text = "%s" % current_ammo

var current_direction := Types.Direction.RIGHT

@onready var grandma_background: Sprite2D = %GrandmaBackground
@onready var grandma_foreground: Sprite2D = %GrandmaForeground
@onready var dessert_sprite: DessertSprite = %DessertSprite
@onready var ammo_panel: Node2D = $AmmoCounter
@onready var ammo_label: Label = %AmmoLabel
@onready var barrel: CannonBarrel = %CannonBarrel


func _ready() -> void:
	var max_angle = barrel.position.angle_to_point($Cannon/MaxAngle.position)
	var min_angle = barrel.position.angle_to_point($Cannon/MinAngle.position)
	barrel.max_angle = max_angle
	barrel.min_angle = min_angle
	current_ammo = 0
	Events.on_feed.connect(func(x): bark(Types.BarkType.GOOD))
	Events.on_bad_feed.connect(func(x): bark(Types.BarkType.BAD))
	

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		_move(Types.Direction.LEFT, delta)		
	elif Input.is_action_pressed("right"):
		_move(Types.Direction.RIGHT, delta)
	else:
		_stop()
	if moving and not $walk_sfx.playing:
		$walk_sfx.play()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_position = get_local_mouse_position()
		var direction = mouse_position.x / abs(mouse_position.x)
		if direction != current_direction:
			_face(direction)
		
		barrel.point_at(mouse_position)
		
	
	if event.is_action_pressed("shoot"):
		if _has_ammo():
			barrel.shoot(dessert_type, flavour)
			current_ammo -= 1
		else:
			barrel.empty_shot()
		

func reload(_dessert_type: Types.DessertType, _flavour: Types.Flavour) -> void:
	$reload_sfx.play()
	dessert_type = _dessert_type
	flavour = _flavour
	current_ammo = 5
	

func _has_ammo() -> bool:
	return current_ammo > 0
	

func _face(direction: int) -> void:
	current_direction = direction
	$SpeechBubble.flip_h = direction == Types.Direction.LEFT
	if sign($SpeechBubble.position.x) != sign(direction):
		$SpeechBubble.position.x*=-1
	grandma_background.flip_h = direction == Types.Direction.LEFT
	grandma_foreground.flip_h = direction == Types.Direction.LEFT
	barrel.flip_h = direction == Types.Direction.LEFT
	barrel.position.x = -barrel.position.x
	dessert_sprite.position.x = -dessert_sprite.position.x
	ammo_panel.position.x = -ammo_panel.position.x
	

func _move(direction: int, delta: float) -> void:
	# TODO: moving animation?
	progress += direction * speed * delta
	moving = true
	

func _stop() -> void:
	# TODO: idle animation?
	moving = false

func bark(type:Types.BarkType) -> void:
	if type == Types.BarkType.GOOD:
		$giggle_sfx.play()
	$SpeechBubble.show_text(Types.BARKS[type].pick_random())
