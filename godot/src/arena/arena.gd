extends Node

const HAPPINESS_MAP={
	Types.ChildState.CRYING:-5.0,
	Types.ChildState.ABOUT_TO_CRY:-1.5,
	Types.ChildState.UPSET:-.75

}
const BAD_FEED_HAPPINESS_PENALTY = -3
const FEED_HAPPINESS_BONUS = 5
const CRY_HAPPINESS_PENALTY=-5
const NO_CRY_HAPPINESS_BONUS=0

const AreaScene:PackedScene = preload("res://src/arena/detection_area.tscn")
const ChildScene:PackedScene = preload("res://src/child/child.tscn")
const ScoreScene:=preload("res://src/child/ScoreLabel.tscn")

@export var area_rows := 4
@export var y_area_margin := 200.0

@export var initial_spawn_rate := 10.0
@export var time_to_double := 80.0
@onready var spawn_timer: Timer = $SpawnTimer
@onready var timer: Timer = $Timer

var child_count:int = 0
var start_time:int=0
var score=0
var happiness:=100.0
var player_name="test_player"

func _ready() -> void:
	_init_areas()
	start_time = Time.get_ticks_msec()
	Events.child_entered_arena.connect(func(x): child_count+= 1)
	Events.child_exited_arena.connect(func(x): child_count-= 1)
	Events.on_feed.connect(_on_feed)
	Events.score_changed.emit(score, false)
	Events.happiness_changed.emit(happiness)
	Events.on_feed.connect(func(x):happiness+=FEED_HAPPINESS_BONUS; Events.happiness_changed.emit(happiness))
	Events.on_bad_feed.connect(func(x):happiness+=BAD_FEED_HAPPINESS_PENALTY; Events.happiness_changed.emit(happiness))
	#await Leaderboards.post_guest_score("cake-sharing-happiness-score-S7ha", 100.0, "player_name")
	

func _input(event):
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	

func get_time_from_start()->int:
	return (Time.get_ticks_msec()-start_time) / 1000.0

func _init_areas() -> void:
	for i in range(area_rows):
		var area_left = AreaScene.instantiate()
		area_left.direction = Types.Direction.LEFT
		$Areas.add_child(area_left)
		area_left.global_position = DetectionArea.SIZE / 2.0 + Vector2(0,y_area_margin+i*DetectionArea.SIZE.y)

		var area_right = AreaScene.instantiate()
		area_right.direction = Types.Direction.RIGHT
		$Areas.add_child(area_right)
		area_right.global_position = DetectionArea.SIZE / 2.0 + Vector2(DetectionArea.SIZE.x,0) + Vector2(0,y_area_margin+i*DetectionArea.SIZE.y)

func spawn_child():
	var area := get_best_area()
	var child = ChildScene.instantiate()
	child.global_position = area.get_spawn_point()
	$ArenaArea/Kids.add_child(child)
	Logger.info("Child added %s at %s" % [child.name, child.global_position])
	child.set_initial_velocity(area.direction*-1)
	
func get_best_area()-> DetectionArea:
	var best_count := 1000
	var candidates = []
	for a in get_tree().get_nodes_in_group("areas"):
		var count:int = a.get_body_count()
		if count < best_count:
			candidates = [a]
			best_count = count
		elif count == best_count:
				candidates.append(a)
				
	return candidates.pick_random()
		


func _on_spawn_timer_timeout() -> void:
	if child_count < get_max_children():
		spawn_child()	
		var interval = initial_spawn_rate / pow(2,get_time_from_start() / time_to_double)
		Logger.debug("next spawn in %d s" % [interval])
		spawn_timer.wait_time = interval
		spawn_timer.start()
	else:
		spawn_timer.wait_time = 1
		spawn_timer.start()
		
		

func _on_arena_area_body_entered(body: Node2D) -> void:
	if body.has_method("entered_arena"):
		body.entered_arena()		


func _on_arena_area_body_exited(body: Node2D) -> void:
	if body.has_method("exited_arena"):
		body.exited_arena()

func _on_feed(child:Child):
	var l = ScoreScene.instantiate()
	l.global_position = child.global_position-Vector2(-64, 300)
	var score_delta = Types.ScoreTable[child.get_state_from_happiness()]
	l.set_score(score_delta)
	add_child(l)
	score += score_delta
	Events.score_changed.emit(score, true)
	_update_hud()
	
func _update_hud():
	Logger.info("new score: %d" % [score])
	
func get_max_children()->int:
	return 7

func update_happiness():
	var happiness_delta:float = 0.0
	for c in get_tree().get_nodes_in_group("children"):
		if c.state in HAPPINESS_MAP.keys():			
			happiness_delta+=HAPPINESS_MAP[c.state]
	if happiness_delta == 0.0:
		happiness_delta += NO_CRY_HAPPINESS_BONUS
	happiness = clamp(happiness + happiness_delta, 0, 100)#TODO const for 100
	Events.happiness_changed.emit(happiness)
	check_game_over()
	
func check_game_over():
	if happiness == 0:
		Logger.info("Game over!")
		get_tree().quit()
		
func _on_tick_timer_timeout() -> void:
	update_happiness()
	Events.tick.emit()
