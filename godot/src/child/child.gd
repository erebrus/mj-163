extends CharacterBody2D
class_name Child

const MIN_DIRECTION_CHANGE_TIME = 20 * 1000
const SPEED = 100.0
const MAX_Y = 960.0

var direction_since 
	
func _physics_process(delta: float) -> void:
	check_crazy_ivan()	
	
	move_and_slide()
	if global_position.y > MAX_Y and velocity.y > 0:
		velocity.y = -velocity.y


func check_crazy_ivan():
	var now = Time.get_ticks_msec()
	if now - direction_since > MIN_DIRECTION_CHANGE_TIME and randf() < .001:
		Logger.info("%s changing direction" % [name])
		velocity.x *= -1
		direction_since = now

func set_initial_velocity ( direction:Types.Direction ) -> void:
	velocity = Vector2(direction,randi_range(-30,30)/100.0)*SPEED
	direction_since = Time.get_ticks_msec()

func entered_arena()->void:
	Logger.info("Child %s entered arena" % [name])
	Events.child_entered_arena.emit(self)
	
func exited_arena()->void:
	Events.child_exited_arena.emit(self)
	Logger.info("Child %s left arena" % [name])
	call_deferred("queue_free")

func feed(cake)->void:
	Events.on_feed.emit(self, cake)
	Logger.info("Child %s fed with %s" % [name, cake.name])
	call_deferred("queue_free")
	
