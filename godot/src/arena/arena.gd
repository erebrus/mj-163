extends Node2D

const AreaScene:PackedScene = preload("res://src/arena/detection_area.tscn")
const ChildScene:PackedScene = preload("res://src/child/child.tscn")

@export var area_rows :=3
@export var y_area_margin := 100.0

@onready var spawn_timer: Timer = $SpawnTimer

var child_count:int = 0
var start_time:int=0
var score=0
var player_name="test_player"

func _ready() -> void:
	_init_areas()
	start_time = Time.get_ticks_msec()
	Events.child_entered_arena.connect(func(x): child_count+= 1)
	Events.child_exited_arena.connect(func(x): child_count-= 1)
	Events.on_feed.connect(_on_feed)
	#await Leaderboards.post_guest_score("cake-sharing-happiness-score-S7ha", 100.0, "player_name")
	
func get_time_from_start()->int:
	return Time.get_ticks_msec()-start_time

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
	add_child(child)
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
	spawn_child()


func _on_arena_area_body_entered(body: Node2D) -> void:
	if body.has_method("entered_arena"):
		body.entered_arena()		


func _on_arena_area_body_exited(body: Node2D) -> void:
	if body.has_method("exited_arena"):
		body.exited_arena()

func _on_feed(child:Child, cake):
	score += Types.ScoreTable[child.state]
	_update_hud()
	
func _update_hud():
	Logger.info("new score: %d" % [score])
	
