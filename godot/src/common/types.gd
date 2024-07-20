extends Node

const DESSERT_TEXTURES = {
	Types.DessertType.Cupcake: preload("res://assets/gfx/desserts/cupcake.png"),
	Types.DessertType.Cake: preload("res://assets/gfx/desserts/cheesecake.png"),
	Types.DessertType.Donut: preload("res://assets/gfx/desserts/donut.png"),
}

# TODO: replace whoever is using this with DessertSprite?
var CakeTextures := DESSERT_TEXTURES.values()


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
