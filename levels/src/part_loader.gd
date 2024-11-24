@tool
extends Node


func load_part(part: Part, path: Path3D):
	var length = path.curve.get_baked_length()

	if not is_instance_valid(part):
		return

	path.add_child(part)

	# Get lastest two points in the curve and the direction between them
	var curve_points: int = path.curve.point_count
	var last_position: Vector3 = path.curve.get_point_position(curve_points -1)
	var penultimate_position: Vector3 = path.curve.get_point_position(curve_points -2)
	var direction: Vector3 = penultimate_position.direction_to(last_position)

	# Rotate the part so that it matches the path direction
	part.look_at_from_position(penultimate_position, last_position, Vector3.UP, false)

	# Set its final position at the end of the curve
	part.global_position = last_position

	# Add local object path points - if any - to the level curve
	if part.has_path == true:
		var part_curve: Curve3D = part.part_path.curve
		if part_curve.get_point_position(0) != Vector3.ZERO:
			path.curve.add_point(part.to_global(part_curve.get_point_position(0)))
		for i: int in part_curve.point_count -1:
			path.curve.add_point(part.to_global(part_curve.get_point_position(i +1)))
	else:
		# Get part AABB to add next point at the end of the part
		var part_aabb: AABB = _calculate_spatial_bounds(part, false)
		path.curve.add_point(last_position + (direction * part_aabb.size.z))

	return path.curve.get_baked_length() - length

func _calculate_spatial_bounds(parent : Node3D, exclude_top_level_transform: bool) -> AABB:
	var bounds : AABB = AABB()
	if parent is VisualInstance3D:
		bounds = (parent as VisualInstance3D).get_aabb();

	for i: int in range(parent.get_child_count()):
		var child = parent.get_child(i)
		if child is VisualInstance3D:
			var child_bounds : AABB = _calculate_spatial_bounds(child, false)
			if bounds.size == Vector3.ZERO && parent:
				bounds = child_bounds
			else:
				bounds = bounds.merge(child_bounds)

	if bounds.size == Vector3.ZERO && !parent:
		bounds = AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4))
	if !exclude_top_level_transform:
		bounds = parent.transform * bounds
	return bounds
