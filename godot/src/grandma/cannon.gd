class_name CannonBarrel extends Node2D

const GUIDE_LENGTH = 400
const DEFAULT_CAKE = preload("res://src/grandma/cake/bullet.tscn")

const CAKES = {}


@export var targetting_assist:= true:
	set(value):
		if value == targetting_assist:
			return
		
		targetting_assist = value
		if targetting_guide != null:
			targetting_guide.visible = targetting_assist
	

var flip_h: bool = false:
	set(value):
		if value == flip_h:
			return
		flip_h = value
		
		if flip_h:
			max_angle = - PI - max_angle 
			min_angle = - PI - min_angle
			rotation = rotation - PI/2
		else:
			max_angle = - PI - max_angle
			min_angle = - PI - min_angle
			rotation = rotation + PI/2
	
var max_angle: float
var min_angle: float


@onready var targetting_guide: Line2D = $Line2D
@onready var bullet_spawn: Marker2D = $BulletSpawn


func _ready() ->void:
	targetting_guide.visible = targetting_assist
	targetting_guide.points = [
		Vector2(0,0),
		Vector2(0, -GUIDE_LENGTH)
	]
	

func point_at(target: Vector2) -> void:
	var angle = position.angle_to_point(target)
	Logger.debug("target %s, position %s" % [target.x, position.x])
	Logger.debug("%.4fº should be between %.4fº , %.4fº" % [rad_to_deg(angle), rad_to_deg(min_angle), rad_to_deg(max_angle)])
	if flip_h:
		if angle < 0 and angle > max_angle:
			Logger.debug("Cannot turn cannon towards %s -> %.4fº outside of range" % [target, rad_to_deg(angle)])
			angle = max_angle
		if min_angle < 0 and (angle < min_angle or angle > 0):
			Logger.debug("Cannot turn cannon towards %s -> %.4fº outside of range" % [target, rad_to_deg(angle)])
			angle = min_angle
		if min_angle > 0 and angle > 0 and angle < min_angle:
			Logger.debug("Cannot turn cannon towards %s -> %.4fº outside of range" % [target, rad_to_deg(angle)])
			angle = min_angle
	else:
		if angle < 0 and angle < max_angle:
			Logger.debug("Cannot turn cannon towards %s -> %.4fº outside of range" % [target, rad_to_deg(angle)])
			angle = max_angle
		if min_angle < 0 and (angle > min_angle or angle > 0):
			Logger.debug("Cannot turn cannon towards %s -> %.4fº outside of range" % [target, rad_to_deg(angle)])
			angle = min_angle
		if min_angle > 0 and angle > 0 and angle > min_angle:
			Logger.debug("Cannot turn cannon towards %s -> %.4fº outside of range" % [target, rad_to_deg(angle)])
			angle = min_angle
	
	rotation = angle + PI / 2
	

func shoot(dessert_type: Types.DessertType, flavour: Types.Flavour) -> void:
	Logger.info("Shooting at angle %.4fº" % rotation_degrees)
	var BulletScene = DEFAULT_CAKE
	if CAKES.has(dessert_type):
		BulletScene = CAKES[dessert_type]
	
	var bullet = BulletScene.instantiate()
	bullet.global_position = bullet_spawn.global_position
	get_tree().root.add_child(bullet)
	
	bullet.shoot(dessert_type, flavour, rotation)
	
