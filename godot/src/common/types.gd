extends Node

enum ChildState{CRYING, ABOUT_TO_CRY, UPSET, NORMAL, EATING}
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

const ScoreTable := {
	ChildState.CRYING : 50,
	ChildState.ABOUT_TO_CRY : 200,
	ChildState.UPSET : 500,
	ChildState.NORMAL : 1000,
	
}
