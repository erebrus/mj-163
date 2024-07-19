extends Node2D

const GUIDE_LENGTH = 400
const CAKES = {
	Types.Cakes.StrawberryCupcake: preload("res://src/cannon/cake/types/strawberry_cake.tscn"),
	Types.Cakes.ChocolateCupcake: preload("res://src/cannon/cake/types/chocolate_cake.tscn"),
}

@export var targetting_assist:= true:
	set(value):
		if value == targetting_assist:
			return
		
		targetting_assist = value
		targetting_guide.visible = targetting_assist
	

@export var max_angle_degrees:= 80:
	set(value):
		max_angle_degrees = value
		max_angle = deg_to_rad(max_angle_degrees)

var max_angle: float = deg_to_rad(max_angle_degrees)

@onready var targetting_guide: Line2D = $Line2D


@export var cake_type:= Types.Cakes.StrawberryCupcake


func _ready() ->void:
	targetting_guide.points = [
		Vector2(0,0),
		Vector2(0, -GUIDE_LENGTH)
	]
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		point_at(event.global_position - position)
	
	if event.is_action_pressed("shoot"):
		shoot()
	
	if event.is_action_pressed("wheel_up"):
		change_ammo(1)
	if event.is_action_pressed("wheel_down"):
		change_ammo(-1)
	

func point_at(target: Vector2) -> void:
	var angle = target.angle()
	if angle < (-max_angle - PI/2) or angle > max_angle - PI / 2:
		Logger.debug("Cannot turn cannon towards %s -> %.4fº outside of range" % [target, rad_to_deg(angle)])
		return
	
	rotation = angle + PI / 2
	

func shoot() -> void:
	Logger.info("Shooting at angle %.4fº" % rotation_degrees)
	assert(CAKES.has(cake_type))
	
	var bullet = CAKES[cake_type].instantiate()
	bullet.position = position
	get_parent().add_child(bullet)
	
	bullet.shoot(rotation)
	

func change_ammo(direction: int) -> void:
	cake_type = posmod(int(cake_type) + direction, CAKES.size())
