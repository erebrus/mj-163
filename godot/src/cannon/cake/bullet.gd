extends Area2D

@export var start_speed: float = 500

@export var type: Types.Cakes
@export var tags: Array[Types.CakeTags]


var velocity: Vector2

func _physics_process(delta: float) -> void:
	position += velocity * delta
	

func shoot(angle: float) -> void:
	velocity = Vector2(start_speed, 0).rotated(angle - PI/2)
	visible = true
	


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("children"):
		body.feed(self)
		call_deferred("queue_free")
