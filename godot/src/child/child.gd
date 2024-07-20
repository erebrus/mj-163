extends CharacterBody2D
class_name Child

const MIN_DIRECTION_CHANGE_TIME = 20 * 1000
const SPEED = 100.0
const MAX_Y = 960.0

var direction_since 
var on_screen_since=-1
var happiness = 100
	
func _physics_process(delta: float) -> void:
	_update_happiness()
	check_crazy_ivan()	
	
	move_and_slide()
	if global_position.y > MAX_Y and velocity.y > 0:
		velocity.y = -velocity.y

func _update_happiness()->void:
	if happiness>0:
		happiness = clamp(100 - get_time_on_screen()/1000, 0, 100)
		
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
	on_screen_since = Time.get_ticks_msec()
	
func exited_arena()->void:
	Events.child_exited_arena.emit(self)
	Logger.info("Child %s left arena" % [name])
	on_screen_since = -1
	call_deferred("queue_free")

func feed(cake)->void:
	Events.on_feed.emit(self, cake)
	Logger.info("Child %s fed with %s" % [name, cake.name])
	call_deferred("queue_free")
	
func is_on_screen()->bool:
	return on_screen_since!=-1
	
func get_time_on_screen()-> int:
	if on_screen_since>-1:
		return Time.get_ticks_msec() - on_screen_since
	else:
		return -1
