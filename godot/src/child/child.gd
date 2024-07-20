extends CharacterBody2D
class_name Child

const MIN_DIRECTION_CHANGE_TIME = 20 * 1000
const SPEED = 100.0
const MIN_Y = 60.0
const MAX_Y = 900.0

var direction_since 
var on_screen_since=-1
var happiness = 100
var state := Types.ChildState.NORMAL

func _physics_process(delta: float) -> void:
	_update_happiness()
	if state != Types.ChildState.CRYING:	
		check_crazy_ivan()	
		move_and_slide()
		if global_position.y > MAX_Y and velocity.y > 0 or \
			global_position.y < MIN_Y and velocity.y < 0:
			velocity.y = -velocity.y

func _update_happiness()->void:
	if state == Types.ChildState.EATING:
		return
	if happiness>0:
		happiness = clamp(100 - get_time_on_screen()/1000*4, 0, 100)
	_update_state()
	
func _update_state():
	if happiness == 0:
		state = Types.ChildState.CRYING
		$Polygon2D.color = Color.RED
	elif happiness < 10:
		state = Types.ChildState.ABOUT_TO_CRY
		$Polygon2D.color = Color.ORANGE
	elif happiness < 50:
		state = Types.ChildState.UPSET
		$Polygon2D.color = Color.YELLOW
	else:
		state = Types.ChildState.NORMAL
		$Polygon2D.color = Color.WHITE


func check_crazy_ivan():
	var now = Time.get_ticks_msec()
	if now - direction_since > MIN_DIRECTION_CHANGE_TIME and randf() < .005:
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
	state = Types.ChildState.EATING
	$Polygon2D.color = Color.SEA_GREEN
	Logger.info("Child %s fed with %s" % [name, cake.name])
	
	
func is_on_screen()->bool:
	return on_screen_since!=-1
	
func get_time_on_screen()-> int:
	if on_screen_since>-1:
		return Time.get_ticks_msec() - on_screen_since
	else:
		return -1
