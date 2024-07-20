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


func _ready() -> void:
	var separation = WIDTH / float(num_stands)
	var offset = separation / 2 - WIDTH / 2
	for i in num_stands:
		var stand = Stand.instantiate()
		stand.position = Vector2(offset + i * separation, stand_height)
		add_child(stand)
		stands.append(stand)
