extends PathFollow2D


@export var speed:= 500


var cake_type:= Types.Cakes.StrawberryCupcake
var current_direction := Types.Direction.RIGHT


@onready var grandma_sprite: Sprite2D = %GrandmaSprite
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
		barrel.point_at(get_local_mouse_position())
	
	if event.is_action_pressed("shoot"):
		barrel.shoot(cake_type)
	

func _change_ammo(direction: int) -> void:
	cake_type = posmod(int(cake_type) + direction, Types.Cakes.size())
	barrel.cake_type = cake_type
	

func _face(direction: int) -> void:
	current_direction = direction
	grandma_sprite.flip_h = direction == Types.Direction.LEFT
	barrel.flip_h = direction == Types.Direction.LEFT
	barrel.position.x = -barrel.position.x
	

func _move(direction: int, delta: float) -> void:
	if direction != current_direction:
		_face(direction)
	
	# TODO: moving animation?
	progress += direction * speed * delta
	

func _stop() -> void:
	# TODO: idle animation?
	pass
