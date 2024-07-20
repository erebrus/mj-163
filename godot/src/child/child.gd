extends CharacterBody2D
class_name Child

const EATING_TIME=3
const REACTING_TIME=3
const INITIAL_HAPPINESS_RATE =5.0
const TIME_TO_HIGHER_RATE :=30.0
const MAX_HAPPINESS_RATE :=15.0

const MIN_DIRECTION_CHANGE_TIME = 20 * 1000
const SPEED = 100.0
const MIN_Y = 60.0
const MAX_Y = 900.0

var direction_since 
var on_screen_since=-1
var happiness = 100
var state := Types.ChildState.NORMAL

#func _ready() -> void:
	#Events.tick.connect(_on_tick)
func _physics_process(delta: float) -> void:	
	_update_happiness(delta)
	if should_move():
		if not state == Types.ChildState.LEAVING:	
			check_crazy_ivan()	
		move_and_slide()
		if global_position.y > MAX_Y and velocity.y > 0 or \
			global_position.y < MIN_Y and velocity.y < 0:
			velocity.y = -velocity.y

func get_state_from_happiness():
	if happiness == 0:
		return Types.ChildState.CRYING
	elif happiness < 30:
		return Types.ChildState.ABOUT_TO_CRY
	elif happiness < 60:
		return Types.ChildState.UPSET
	else:
		return Types.ChildState.NORMAL

#func _on_tick():
#	_update_happiness()
	
func _update_happiness(delta:float)->void:
	if state == Types.ChildState.EATING:
		return
	if happiness>0:
		 #amountLostPerSecond = initial + (t/r)
		var rate = clamp(INITIAL_HAPPINESS_RATE + (get_time_on_screen()/TIME_TO_HIGHER_RATE),1.0,MAX_HAPPINESS_RATE)*delta
		#happiness = clamp(100 - get_time_on_screen()/1000*4, 0, 100)
		happiness = clamp(happiness- rate, 0, 100)
	_update_state()
	
func _update_state():
	match state:
		Types.ChildState.EATING:
			$Polygon2D.color = Color.GRAY
		Types.ChildState.BAD_REACTION:
			$Polygon2D.color = Color.PURPLE
		Types.ChildState.GOOD_REACTION:
			$Polygon2D.color = Color.GREEN_YELLOW
		Types.ChildState.LEAVING:
			$Polygon2D.color = Color.SEA_GREEN
		_:
			state = get_state_from_happiness()
			match state:
				Types.ChildState.CRYING:
					$Polygon2D.color = Color.RED
				Types.ChildState.ABOUT_TO_CRY:
					$Polygon2D.color = Color.ORANGE
				Types.ChildState.UPSET:
					$Polygon2D.color = Color.YELLOW
				Types.ChildState.NORMAL:
					$Polygon2D.color = Color.WHITE


func check_crazy_ivan():
	var now = Time.get_ticks_msec()
	if now - direction_since > MIN_DIRECTION_CHANGE_TIME and randf() < .005:
		Logger.debug("%s changing direction" % [name])
		velocity.x *= -1
		direction_since = now

func set_initial_velocity ( direction:Types.Direction ) -> void:
	velocity = Vector2(direction,randi_range(-30,30)/100.0)*SPEED
	direction_since = Time.get_ticks_msec()

func entered_arena()->void:
	Logger.debug("Child %s entered arena" % [name])
	Events.child_entered_arena.emit(self)
	on_screen_since = Time.get_ticks_msec()
	
func exited_arena()->void:
	Events.child_exited_arena.emit(self)
	Logger.debug("Child %s left arena" % [name])
	on_screen_since = -1
	call_deferred("queue_free")

func feed(cake)->void:
	
	state = Types.ChildState.EATING
	_update_state()
	Logger.debug("Child %s fed with %s" % [name, cake.name])
	await get_tree().create_timer(EATING_TIME).timeout 
	check_reaction(cake)
	
func check_reaction(cake):
	#TODO check cake type
	Events.on_feed.emit(self, cake)
	state = Types.ChildState.GOOD_REACTION
	_update_state()
	await get_tree().create_timer(REACTING_TIME).timeout 	
	leave()

func leave():
	state = Types.ChildState.LEAVING
	_update_state()
	if global_position.x > 1920/2.0 and velocity.x < 0 or \
		global_position.x < 1920/2.0 and velocity.x > 0:
			velocity.x *=-1

func should_move()->bool:
	return state == Types.ChildState.ABOUT_TO_CRY or \
			state == Types.ChildState.UPSET or \
			state == Types.ChildState.NORMAL or \
			state == Types.ChildState.LEAVING

func is_on_screen()->bool:
	return on_screen_since!=-1
	
func get_time_on_screen()-> float:
	if on_screen_since>-1:
		return (Time.get_ticks_msec() - on_screen_since) / 1000.0
	else:
		return -1
