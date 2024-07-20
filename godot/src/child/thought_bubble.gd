extends Node2D

@export var pattern:=Types.Pattern:
	set(v):
		pattern = v
		$Bubble/Content.texture = Types.PATTERN_TEXTURES[pattern]


func pattern_matches(dessert_type:Types.DessertType, flavour:Types.Flavour)->bool:
	match pattern:
		Types.Pattern.Chocolate:
			return flavour == Types.Flavour.Chocolate
		Types.Pattern.Strawberry:
			return flavour == Types.Flavour.Strawberry
		Types.Pattern.Cake:
			return dessert_type == Types.DessertType.Cake
		Types.Pattern.Cupcake:
			return dessert_type == Types.DessertType.Cupcake
		Types.Pattern.Donut:
			return dessert_type == Types.DessertType.Donut
	return false
