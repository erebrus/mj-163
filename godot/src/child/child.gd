extends CharacterBody2D
class_name Child

const EATING_TIME=1
const REACTING_TIME=2
const INITIAL_HAPPINESS_RATE =5.0
const TIME_TO_HIGHER_RATE :=30.0
const MAX_HAPPINESS_RATE :=15.0




const MIN_DIRECTION_CHANGE_TIME = 6 
const MAX_DIRECTION_CHANGE_TIME = 20 
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

var cry_tween: Tween


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction_timer: Timer = $DirectionTimer
@onready var head_sprite: Sprite2D = %Head
@onready var body_sprite: Sprite2D = %Body
@onready var head_pivot: Node2D = $Sprites/HeadPivot

@onready var right_cry_particles: GPUParticles2D = $Sprites/HeadPivot/Head/RightCryParticles
@onready var left_cry_particles: GPUParticles2D = $Sprites/HeadPivot/Head/LeftCryParticles

@onready var eating_sfx: AudioStreamPlayer2D = $Sfx/eating_sfx
@onready var happy_sfx: AudioStreamPlayer2D = $Sfx/happy_sfx
@onready var sad_sfx: AudioStreamPlayer2D = $Sfx/sad_sfx
@onready var walk_sfx: AudioStreamPlayer2D = $Sfx/walk_sfx
@onready var cry_sfx: AudioStreamPlayer2D = $Sfx/cry_sfx


func _ready() -> void:
	happiness= 100+randi_range(-20,10)
	_choose_cake()
	_update_state()
	var wt = MIN_DIRECTION_CHANGE_TIME + randf()*MIN_DIRECTION_CHANGE_TIME
	
	direction_timer.wait_time = wt
	direction_timer.start()
	#
	#HyperLog.log(self).text("velocity>round")
	#HyperLog.log(self).text("position>round")
	#HyperLog.log(self).text("state")
	#HyperLog.log(self).size = Vector2(100,100)
	
	

func _choose_cake():
	var bubble = $ThoughtBubble
	$ThoughtBubble.thought_pattern = Types.Pattern.values().pick_random()
	
func _physics_process(delta: float) -> void:	
	_update_happiness(delta)
	
	right_cry_particles.emitting = state == Types.ChildState.CRYING
	left_cry_particles.emitting = state == Types.ChildState.CRYING
	
	$ThoughtBubble.flip = velocity.x > 0
		
	if should_move():
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
		var new_state = get_state_from_happiness()
		if new_state != state:
			if new_state == Types.ChildState.CRYING:
				_cry()
			else:
				_stop_crying()
			state = new_state
	
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
		if state != Types.ChildState.CRYING:
			head_pivot.rotation = 0

func change_direction():	
	velocity.y = randi_range(-30,30)/100.0*SPEED
	if randf()>.3:
		velocity.x *= -1

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

func feed(cake, flavour)->void:	
	_hide_baloon()
	if $ThoughtBubble.pattern_matches(cake, flavour):
		Events.on_feed.emit(self)
		state = Types.ChildState.EATING
		eating_sfx.play()
		_update_state()
		Logger.debug("Child %s fed with %s" % [name, cake])
		await get_tree().create_timer(EATING_TIME).timeout 
		state = Types.ChildState.GOOD_REACTION
		happy_sfx.play()
		_update_state()
		await get_tree().create_timer(REACTING_TIME).timeout 	
		leave()
	else:
		state = Types.ChildState.BAD_REACTION
		Events.on_bad_feed.emit(self)
		sad_sfx.play()
		_update_state()
		await get_tree().create_timer(REACTING_TIME).timeout		
		state = get_state_from_happiness()
		_show_baloon()
	

func _hide_baloon():
	$ThoughtBubble.hide()

func _show_baloon():
	$ThoughtBubble.show()

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
	return $ThoughtBubble.visible


func _on_direction_timer_timeout() -> void:
	if state != Types.ChildState.LEAVING:	
		if should_move:
			change_direction()	
		direction_timer.wait_time = MIN_DIRECTION_CHANGE_TIME+  randf()*(MAX_DIRECTION_CHANGE_TIME-MIN_DIRECTION_CHANGE_TIME)
		direction_timer.start()
	

func _cry() -> void:
	if cry_tween:
		cry_tween.kill()
	cry_tween = create_tween()
	cry_sfx.play() #TODO repeat? loop?
	var angle = randf_range(25, 50)
	if randi() % 2 == 1:
		angle = -angle
	
	head_pivot.rotation = 0
	cry_tween.tween_property(head_pivot, "rotation", deg_to_rad(angle), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	cry_tween.tween_interval(randf_range(1, 4))
	cry_tween.tween_property(head_pivot, "rotation", 0, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	cry_tween.tween_interval(randf_range(0, 0.5))
	cry_tween.tween_callback(_cry)
	


func _stop_crying() -> void:
	if cry_tween:
		cry_tween.kill()
	
