extends Node2D

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

@export var initial_velocity=1
@export var accel=3

var velocity
func _ready() -> void:
	velocity = initial_velocity	
func _physics_process(delta: float) -> void:
	velocity +=accel
	position.y-=velocity*delta
	
func set_score(v):
	$Label.text="%d" % [v]
	
func _on_timer_timeout() -> void:
	call_deferred("queue_free")
