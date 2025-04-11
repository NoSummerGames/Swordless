@tool
class_name PartLoader
extends Node


static var vertex_count: int = 0

func load_part(part: Part, path: Path3D, create_collision: bool = true) -> float:
	var length: float = path.curve.get_baked_length()

	if not is_instance_valid(part):
		return float()

	path.add_child(part)

	# Get lastest two points in the curve and the direction between them
	var curve_transform: Transform3D = path.curve.sample_baked_with_rotation(path.curve.get_baked_length(), false, true)

	# Set its final position at the end of the curve
	part.global_transform = curve_transform

	# Add local object path points - if any - to the level curve
	if part.has_path == true:
		var part_curve: Curve3D = part.part_path.curve
		if part_curve.get_point_position(0) != Vector3.ZERO:
			path.curve.add_point(part.to_global(part_curve.get_point_position(0)))
		for i: int in part_curve.point_count -1:
			# Add a point in past curve transform to preserve overall path orientation
			path.curve.add_point(part.to_global(part_curve.get_point_position(i +1)) + curve_transform.basis.z * 0.1)
			path.curve.add_point(part.to_global(part_curve.get_point_position(i +1)))
	else:
		# Get part AABB to add next point at the end of the part
		var part_aabb: AABB = _calculate_spatial_bounds(part, true)
		path.curve.add_point(curve_transform.origin + (-curve_transform.basis.z * part_aabb.size.z))


	for child: Node in Utilities.get_all_children(part):
		if child is MeshInstance3D and not child.is_in_group("gameplay_elements"):
			var mesh_instance: MeshInstance3D = child

		# Set materials
			const ACCENT_MATERIAL: String = "Black"
			if mesh_instance.get_active_material(0).resource_name.begins_with(ACCENT_MATERIAL):
				if path.accent_material:
					mesh_instance.set_surface_override_material(0, path.accent_material)
			else:
				if path.default_material:
					mesh_instance.set_surface_override_material(0, path.default_material)

			# Get vertex count
			var mesh_array = ArrayMesh.new()
			mesh_array.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_instance.mesh.surface_get_arrays(0))
			var mdt = MeshDataTool.new()
			mdt.create_from_surface(mesh_array, 0)
			vertex_count += mdt.get_vertex_count()

			if create_collision:
				# Set meshes collisions and static body 3D
				if mesh_instance.find_child("StaticBody3D") == null:
					mesh_instance.create_trimesh_collision()

	return path.curve.get_baked_length() - length


func _calculate_spatial_bounds(parent : Node3D, exclude_top_level_transform: bool) -> AABB:
	var bounds : AABB = AABB()
	if parent is VisualInstance3D:
		bounds = (parent as VisualInstance3D).get_aabb();

	for i: int in range(parent.get_child_count()):
		var child: Node = parent.get_child(i)
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
