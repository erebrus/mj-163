extends Node

const DESSERT_TEXTURES = {
	Types.DessertType.Cupcake: preload("res://assets/gfx/desserts/cupcake.png"),
	Types.DessertType.Cake: preload("res://assets/gfx/desserts/cheesecake.png"),
	Types.DessertType.Donut: preload("res://assets/gfx/desserts/donut.png"),
}

# TODO: replace whoever is using this with DessertSprite?
var CakeTextures := DESSERT_TEXTURES.values()

enum ChildSkin {DARK, MEDIUM, LIGHT}
enum ChildHair {BROWN_PIGTAILS, RED_PIGTAILS, BROWN_SHORT, RED_SHORT}
enum ChildClothes {GREEN_OVERALLS, CYAN_OVERALLS, BLUE_OVERALLS, CYAN_TSHIRT, PINK_TSHIRT, GREEN_TSHIRT}

enum ChildState{CRYING, ABOUT_TO_CRY, UPSET, NORMAL, EATING, BAD_REACTION, GOOD_REACTION, LEAVING}
enum Direction{LEFT=-1, RIGHT=1}

enum Cakes {
	ChocolateCupcake,
	StrawberryCupcake
}

enum DessertType {
	Cupcake,
	Cake,
	Donut,
}


const ScoreTable := {
	ChildState.CRYING : 50,
	ChildState.ABOUT_TO_CRY : 200,
	ChildState.UPSET : 500,
	ChildState.NORMAL : 1000,
	
}

const StateTable := {
	ChildState.CRYING: "cry",
	ChildState.ABOUT_TO_CRY: "walk-upset",
	ChildState.UPSET: "walk-neutral",
	ChildState.NORMAL: "walk-happy",
	ChildState.EATING: "stuffed", 
	ChildState.BAD_REACTION: "disgust", 
	ChildState.GOOD_REACTION: "happy",
	ChildState.LEAVING: "walk-happy",
}

var child_heads = {}
var child_bodies = {}

func _ready():
	var head_path = "res://assets/gfx/kids/faces/skin-%s.%s/%s.png"
	var walking_path = "res://assets/gfx/kids/body-types/clothes-%s-skin-%s-walk.png"
	var sitting_path = "res://assets/gfx/kids/body-types/clothes-%s-skin-%s.png"
	
	for skin in ChildSkin.values():
		child_heads[skin] = {}
		for hair in ChildHair.values():
			child_heads[skin][hair] = {}
			for state in StateTable:
				var file = load(head_path % [int(skin) + 1, int(hair) + 1, StateTable[state]])
				child_heads[skin][hair][state] = file
		
		child_bodies[skin] = {}
		for clothes in ChildClothes.values():
			child_bodies[skin][clothes] = {
				true: load(walking_path % [int(clothes) + 1, int(skin) + 1]),
				false: load(sitting_path % [int(clothes) + 1, int(skin) + 1]),
			}
		
	

func head_texture(state: ChildState, skin: ChildSkin, hair: ChildHair) -> Texture2D:
	return child_heads[skin][hair][state]
	

func body_texture(walking: bool, skin: ChildSkin, clothes: ChildClothes) -> Texture2D:
	return child_bodies[skin][clothes][walking]
