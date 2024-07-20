extends PathFollow2D


@export var speed:= 500


var dessert_type:= Types.DessertType.Cupcake
var current_direction := Types.Direction.RIGHT


@onready var grandma_background: Sprite2D = %GrandmaBackground
@onready var grandma_foreground: Sprite2D = %GrandmaForeground
@onready var dessert_sprite: DessertSprite = %DessertSprite
@onready var barrel: CannonBarrel = %CannonBarrel


func _ready() -> void:
	var max_angle = barrel.position.angle_to_point($Cannon/MaxAngle.position)
	var min_angle = barrel.position.angle_to_point($Cannon/MinAngle.position)
	barrel.max_angle = max_angle
	barrel.min_angle = min_angle
	

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		_move(Types.Direction.LEFT, delta)
	elif Input.is_action_pressed("right"):
		_move(Types.Direction.RIGHT, delta)
	else:
		_stop()
	
	if Input.is_action_just_pressed("wheel_up"):
		_change_ammo(1)
	if Input.is_action_just_pressed("wheel_down"):
		_change_ammo(-1)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("wheel_up"):
		_change_ammo(1)
	if event.is_action_pressed("wheel_down"):
		_change_ammo(-1)
	
	if event is InputEventMouseMotion:
		var mouse_position = get_local_mouse_position()
		var direction = mouse_position.x / abs(mouse_position.x)
		if direction != current_direction:
			_face(direction)
		
		barrel.point_at(mouse_position)
	
	if event.is_action_pressed("shoot"):
		barrel.shoot(dessert_type)
	

func _change_ammo(direction: int) -> void:
	dessert_type = posmod(int(dessert_type) + direction, Types.DessertType.size())
	dessert_sprite.dessert_type = dessert_type
	

func _face(direction: int) -> void:
	current_direction = direction
	grandma_background.flip_h = direction == Types.Direction.LEFT
	grandma_foreground.flip_h = direction == Types.Direction.LEFT
	barrel.flip_h = direction == Types.Direction.LEFT
	barrel.position.x = -barrel.position.x
	dessert_sprite.position.x = -dessert_sprite.position.x
	

func _move(direction: int, delta: float) -> void:
	# TODO: moving animation?
	progress += direction * speed * delta
	

func _stop() -> void:
	# TODO: idle animation?
	pass
