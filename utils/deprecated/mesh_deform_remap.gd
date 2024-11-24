@tool
extends Node

var array_mesh: ArrayMesh

func deform_junctions(parts_arrays: Array[Array], path: Path3D, curve_point: PackedInt32Array):
	var path_t = path.global_transform

	for i in parts_arrays.size():
		#if i != 1:
			#continue
		var cursor: int = 0
		for x in parts_arrays[i].size():
			var part: Part = parts_arrays[i][x]

			if part.has_path == true:
				cursor += 1
				continue

			var part_aabb = _calculate_spatial_bounds(part, true)

			for child in Utilities.get_all_children(part):
				if child is MeshInstance3D:
					_deform_mesh(part, part_aabb, child, path, curve_point[i] + cursor)

			cursor += 1


func _deform_mesh(part: Part, aabb: AABB, mesh: MeshInstance3D, path: Path3D, curve_point: int):
	var mdt: MeshDataTool = _prepare_mesh(mesh)

	for v in mdt.get_vertex_count():
		var local_vert = mdt.get_vertex(v)

		var offset = _find_curve_offset(aabb, path, local_vert.z, curve_point)
		var curve_transform: Transform3D = path.curve.sample_baked_with_rotation(offset)

		var new_pos = local_vert + curve_transform.origin - mesh.global_position
		mdt.set_vertex(v, new_pos)

	array_mesh.clear_surfaces()
	mdt.commit_to_surface(array_mesh)
	mesh.mesh = array_mesh

	#mesh.create_trimesh_collision()

func _find_curve_offset(aabb: AABB, path: Path3D, vertex_z: float, curve_point: int):
	var remapped: float = _float_remap(vertex_z, -aabb.size.z / 2, aabb.size.z / 2, 0, 1)
	var closest_point = path.curve.sample(curve_point, remapped)
	var closest_offset = path.curve.get_closest_offset(closest_point)
	return closest_offset


func _float_remap(x: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	var x_remap = x - from_min
	var from_range: float = (from_max + from_min) - (from_min + from_min)
	var normal: float = x_remap / from_range
	var to_range: float = to_max - to_min

	normal *= to_range
	normal += to_min
#
	return clamp(normal, 0, 1)


func _prepare_mesh(mesh_instance: MeshInstance3D):
		if not mesh_instance is MeshInstance3D:
			push_warning("Skipping a deformation target that is not a MeshInstance3D: " + str(mesh_instance.name))
			return null

		if mesh_instance.mesh == null:
			push_warning("MeshInstance3D has no mesh: " + str(mesh_instance.name))
			return null

		# Create an ArrayMesh from the MeshInstance mesh and set it to a MeshDataTool for processing
		array_mesh = ArrayMesh.new()
		var surface_arrays = mesh_instance.mesh.surface_get_arrays(0)
		if surface_arrays.is_empty():
			push_warning("MeshInstance3D has no valid surface arrays: " + str(mesh_instance.name))
			return null

		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_instance.mesh.surface_get_arrays(0))
		var mdt: MeshDataTool = MeshDataTool.new()

		if mdt.create_from_surface(array_mesh, 0) != OK:
			push_warning("Failed to create MeshDataTool from surface: " + str(mesh_instance.name))
			return null

		return mdt

func _calculate_spatial_bounds(parent : Node3D, exclude_top_level_transform: bool) -> AABB:
	var bounds : AABB = AABB()
	if parent is VisualInstance3D:
		bounds = (parent as VisualInstance3D).get_aabb();

	for i: int in range(parent.get_child_count()):
		var child : Node3D = parent.get_child(i)
		if child:
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


func map(x: Vector3, from_min: Vector3, from_max: Vector3, to_min: Vector3, to_max: Vector3):
	var x_zero = (x - from_min)

	var from_range = (from_max - from_min)
	var to_range = (to_max - to_min)
	var range_diff =  from_range / to_range

	var max_length = range_diff[range_diff.max_axis_index()]

	return to_min +  x_zero / max_length

		#var point_a = path.curve.get_point_position(curve_point)
		#var point_b = path.curve.get_point_position(curve_point + 1)
		#var baked_up = path.curve.get_baked_up_vectors()
		#var remapped: float = _float_remap(local_vert.z, -aabb.size.z / 2, aabb.size.z / 2, 0, 1)
