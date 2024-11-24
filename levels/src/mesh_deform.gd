@tool
extends Node

var array_mesh: ArrayMesh

func deform_mesh(targets: Array[MeshInstance3D], path: Path3D) -> void:
	if path == null or path.curve.get_point_count() == 0:
		push_error("Deform path is not set or has no points.")
		return

	if targets.is_empty():
		push_error("No targets specified for deformation.")
		return

	_deform_mesh(targets, path)



func _deform_mesh(targets: Array[MeshInstance3D], path: Path3D):
	path.curve.remove_point(0)
	var path_t = path.global_transform
	var curve_length = path.curve.get_baked_length()

	_conform_last_control_point(path.curve)

	var end_transf = path.curve.sample_baked_with_rotation(curve_length)

	# Deform each MeshInstance3D targets provided
	for mesh_instance: MeshInstance3D in targets:
		for i in mesh_instance.mesh.get_surface_count():
			mesh_instance.set_surface_override_material(i, mesh_instance.mesh.surface_get_material(i))
		var mdt: MeshDataTool = _prepare_mesh(mesh_instance)
		if mdt == null :
			push_warning("Failed to create MeshDataTool from MeshInstance: " + str(mesh_instance.name))
			continue

		for i in mdt.get_vertex_count():
			# Get vertex global position
			var vertex_global: Vector3 = mdt.get_vertex(i) * mesh_instance.global_transform.inverse()

			var curve_point_transform: Transform3D = path.curve.sample_baked_with_rotation(-vertex_global.z)
#
			var normal = mdt.get_vertex(i).x * curve_point_transform.basis.x
			var binormal = mdt.get_vertex(i).y * curve_point_transform.basis.y

			var new_pos =  curve_point_transform.origin + normal + binormal

			mdt.set_vertex(i, new_pos * mesh_instance.global_transform + Vector3(mesh_instance.global_position.x, mesh_instance.global_position.y, 0))

		array_mesh.clear_surfaces()
		mdt.commit_to_surface(array_mesh)
		mesh_instance.mesh = array_mesh

		mesh_instance.create_trimesh_collision()

# Prevent the last point of the curve to == Vector3.ZERO
func _conform_last_control_point(curve: Curve3D):
	if curve.get_point_in(curve.point_count - 1) == Vector3.ZERO:
		var prev_point: Vector3 = curve.get_point_position(curve.point_count - 2)
		var prev_point_out: Vector3 = curve.get_point_out(curve.point_count - 2)
		var p_point: Vector3 = curve.get_point_position(curve.point_count - 1)

		var direction: Vector3 = p_point.direction_to(prev_point_out + prev_point)
		curve.set_point_in(curve.point_count - 1, direction)

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
