extends Node2D

const WIDTH = 1920
const Stand = preload("res://src/dessert_table/dessert_stand.tscn")


@export var num_stands:= 2

@export var stand_height:= 0:
	set(value):
		stand_height = value
		for child in stands:
			child.position.y = stand_height
	

var stands: Array[DessertStand]

var dessert_bag=[]

func _ready() -> void:
	Events.dessert_spawn_requested.connect(_on_dessert_spawn_requested)
	var separation = WIDTH / float(num_stands)
	var offset = separation / 2 - WIDTH / 2
	for i in num_stands:
		var stand = Stand.instantiate()
		stand.position = Vector2(offset + i * separation, stand_height)
		add_child(stand)
		stands.append(stand)
	for s in stands:
		_on_dessert_spawn_requested(s)

func fill_bag():
	dessert_bag.clear()
	dessert_bag.append_array(Types.DessertType.values())
		
func _on_dessert_spawn_requested(stand):
	if dessert_bag.is_empty():
		fill_bag()
	
	var dessert_type = dessert_bag.pick_random()
	dessert_bag.erase(dessert_type)
	var flavour = Types.Flavour.values().pick_random()
	
	for s in stands:
		if s != stand  and s.has_dessert and s.dessert_type == dessert_type and s.flavour == flavour:
			_on_dessert_spawn_requested(stand)
			return
		else:
			stand.spawn_dessert(dessert_type, flavour)
