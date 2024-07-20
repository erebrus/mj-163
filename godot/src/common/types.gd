extends Node

enum ChildState{CRYING, ABOUT_TO_CRY, UPSET, NORMAL, EATING, BAD_REACTION, GOOD_REACTION, LEAVING}
enum Direction{LEFT=-1, RIGHT=1}

enum Cakes {
	ChocolateCupcake,
	StrawberryCupcake
}


enum CakeTags {
	Chocolate,
	Strawberry,
	Lemon,
	NonGluten,
	Vegan,
}
const CakeTextures := [
	preload("res://assets/gfx/chocolate_cupcake.png"),
	preload("res://assets/gfx/cupcake.png"),
	
]
	

const ScoreTable := {
	ChildState.CRYING : 50,
	ChildState.ABOUT_TO_CRY : 200,
	ChildState.UPSET : 500,
	ChildState.NORMAL : 1000,
	
}
