class_name CollisionComponent
extends Component3D

signal collision_set

@export var visual_instance: VisualInstance3D
@export var min_collision_depth: float = 0.1

var area: Area3D

func _setup() -> void:
	# Add area and collision shape
	set_collision_shape(visual_instance)

func _on_master_state_changed(state: HubObjectState) -> void:
	if area != null:
		match state.is_ray_pickable:
			true: area.input_ray_pickable = true
			false: area.input_ray_pickable = false

# Set a collision shape whenever the visual instance is changed by matching its bouding box
func set_collision_shape(value: VisualInstance3D) -> void:
	if value != null and value.has_method("get_aabb"):
		if area == null:
			area = Area3D.new()
			master.add_child(area)

		var aabb: AABB = value.get_aabb()
		var bounding_box: Vector3 = Vector3(
			aabb.size.x,
			aabb.size.y,
			maxf(aabb.size.z, min_collision_depth))

		for child: CollisionShape3D in area.get_children():
			if child is CollisionShape3D:
				(child.shape as BoxShape3D).size = bounding_box
				return

		var collision: CollisionShape3D = CollisionShape3D.new()
		var shape: Variant = collision.get("shape")
		collision.shape = BoxShape3D.new()
		(collision.shape as BoxShape3D).size = bounding_box
		area.add_child(collision)
		collision_set.emit(area)
