extends Area2D
class_name DetectionArea

const SIZE := Vector2(960,250)
const MARGIN := 50
var direction := Types.Direction.LEFT

	
func get_spawn_point()->Vector2:
	return global_position + Vector2((SIZE.x/2 + MARGIN) * direction,0)

func get_body_count()->int:
	return get_overlapping_bodies().size()
