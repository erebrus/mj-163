extends CharacterBody2D
class_name Child

const EATING_TIME=1
const REACTING_TIME=2
const INITIAL_HAPPINESS_RATE =5.0
const TIME_TO_HIGHER_RATE :=30.0
const MAX_HAPPINESS_RATE :=15.0

const MIN_DIRECTION_CHANGE_TIME = 20 * 1000
const SPEED = 100.0
const MIN_Y = 300.0
const MAX_Y = 760.0

const BUSY_STATES = [
	Types.ChildState.EATING,
	Types.ChildState.BAD_REACTION,
	Types.ChildState.GOOD_REACTION,
	Types.ChildState.LEAVING,
]
	
const WALKING_STATES = [
	Types.ChildState.ABOUT_TO_CRY,
	Types.ChildState.UPSET,
	Types.ChildState.NORMAL,
	Types.ChildState.LEAVING,
]
	
	
var skin = Types.ChildSkin.values().pick_random()
var hair = Types.ChildHair.values().pick_random()
var clothes = Types.ChildClothes.values().pick_random()

var direction_since 
var on_screen_since=-1
var happiness = 100
var state := Types.ChildState.NORMAL
var wanted_cake := Types.Cakes.ChocolateCupcake
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var head_sprite: Sprite2D = %Head
@onready var body_sprite: Sprite2D = %Body


func _ready() -> void:
	happiness= 100+randi_range(-10,10)
	_choose_cake()
	_update_state()
	HyperLog.log(self).text("velocity>round")
	HyperLog.log(self).text("position>round")
	HyperLog.log(self).text("state")
	HyperLog.log(self).size = Vector2(100,100)

func _choose_cake():
	wanted_cake = Types.DessertType.values().pick_random()
	$Balloon.texture = Types.CakeTextures[wanted_cake]
	
func _physics_process(delta: float) -> void:	
	_update_happiness(delta)
	$Balloon.offset.x = 128 if velocity.x > 0 else -128
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
	if not state in BUSY_STATES:
		state = get_state_from_happiness()
	
	var is_walking = state in WALKING_STATES
	
	head_sprite.texture = Types.head_texture(state, skin, hair)
	body_sprite.texture = Types.body_texture(is_walking, skin, clothes)
	
	if is_walking:
		head_sprite.flip_h = velocity.x > 0
		body_sprite.flip_h = velocity.x > 0
		body_sprite.hframes = 2
		var walk_speed = 1
		if state == Types.ChildState.UPSET:
			walk_speed = 0.75
		if state == Types.ChildState.ABOUT_TO_CRY:
			walk_speed = 0.5
			
		animation_player.play("walk", -1, walk_speed)
	else:
		body_sprite.hframes = 1
		animation_player.play("sit")
	

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
	_hide_baloon()
	if cake == wanted_cake:		
		Events.on_feed.emit(self, cake)
		state = Types.ChildState.EATING
		_update_state()
		Logger.debug("Child %s fed with %s" % [name, cake])
		await get_tree().create_timer(EATING_TIME).timeout 
		state = Types.ChildState.GOOD_REACTION
		_update_state()
		await get_tree().create_timer(REACTING_TIME).timeout 	
		leave()
	else:
		state = Types.ChildState.BAD_REACTION
		_update_state()
		await get_tree().create_timer(REACTING_TIME).timeout		
		state = get_state_from_happiness()
		_show_baloon()
	

func _hide_baloon():
	$Balloon.hide()

func _show_baloon():
	$Balloon.show()

func leave():
	state = Types.ChildState.LEAVING
	_update_state()
	if global_position.x > 1920/2.0 and velocity.x < 0 or \
		global_position.x < 1920/2.0 and velocity.x > 0:
			velocity.x *=-1

func should_move()->bool:
	return state in WALKING_STATES

func is_on_screen()->bool:
	return on_screen_since!=-1
	
func get_time_on_screen()-> float:
	if on_screen_since>-1:
		return (Time.get_ticks_msec() - on_screen_since) / 1000.0
	else:
		return -1

func accepts_cake()-> bool:
	return $Balloon.visible
