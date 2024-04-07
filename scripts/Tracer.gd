extends Node
class_name Tracer

@onready var result : Trace = Trace.new()
@onready var collider : ShapeCast3D = get_node("_tracer")

#func _ready():
	#collider.shape.radius *= (1-collider.margin)
	#collider.shape.height = 1.4
	
func tracer(start_position :Vector3, destination :Vector3):
	var longSide = sqrt(collider.margin * collider.margin + collider.margin * collider.margin)
	var maxDistance = start_position.distance_to(destination) + longSide
	
	if (collider.is_colliding()):
		result.fraction = collider.position.distance_to(collider.target_position) / maxDistance
		result.hitCollider = collider.get_collider(0)
		result.hitPoint = collider.get_collision_point(0)
		result.planeNormal = collider.get_collision_normal(0)
	else :
		result.fraction = 1
	# print(collider.is_colliding())	
	# print(collider.shape.radius)	
	# print(result.fraction)
	# print(result.hitCollider)
	# print(result.hitPoint)
	# print(result.planeNormal)
	return result
	
