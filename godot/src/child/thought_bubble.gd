extends Sprite2D
class_name ThoughtBubble

@export var thought_pattern:=Types.Pattern.Chocolate:
	set(v):
		thought_pattern = v
		$Content.texture = Types.PATTERN_TEXTURES[thought_pattern]
		if v  != Types.Flavour.Chocolate and v != Types.Flavour.Strawberry:
			$Content.scale=Vector2.ONE * .75
		else:
			$Content.scale=Vector2.ONE *1.0
			


func pattern_matches(dessert_type:Types.DessertType, flavour:Types.Flavour)->bool:
	match thought_pattern:
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
