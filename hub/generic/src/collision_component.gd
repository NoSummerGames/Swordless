class_name CollisionComponent
extends HubComponent

@export var visual_instance: VisualInstance3D
@export var collision: CollisionShape3D
@export var min_collision_depth: float = 0.1


func _ready() -> void:
	# Add collision shape
	set_collision_shape.call_deferred(visual_instance)

# Set a collision shape whenever the visual instance is changed by matching its bouding box
func set_collision_shape(value: VisualInstance3D) -> void:
	var aabb: AABB = value.get_aabb()
	var bounding_box: Vector3 = Vector3(
		aabb.size.x,
		aabb.size.y,
		maxf(aabb.size.z, min_collision_depth))

	var shape: Shape3D = BoxShape3D.new()
	collision.shape = shape

	shape.size = bounding_box
	collision.transform = value.transform
