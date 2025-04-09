@tool
class_name MeshDeformer
extends Node

var array_mesh: ArrayMesh
var min_z: float

func deform_mesh(targets: Array[MeshInstance3D], path: Path3D, last: bool) -> void:
	if path == null or path.curve.get_point_count() == 0:
		push_error("Deform path is not set or has no points.")
		return

	if targets.is_empty():
		push_error("No targets specified for deformation.")
		return


	# Deform each MeshInstance3D targets provided
	for mesh_instance: MeshInstance3D in targets:

		# Copy mesh materials to the mesh_instance
		for i: int in mesh_instance.mesh.get_surface_count():
			mesh_instance.set_surface_override_material(i, mesh_instance.mesh.surface_get_material(i))

		var mdt: MeshDataTool = _prepare_mesh(mesh_instance)

		if mdt == null :
			push_warning("Failed to create MeshDataTool from MeshInstance: " + str(mesh_instance.name))
			continue


		if last == true:
			min_z = 0
			for i: int in mdt.get_vertex_count():
				if mdt.get_vertex(i).z < min_z:
					min_z = mdt.get_vertex(i).z

		for i: int in mdt.get_vertex_count():
			# Get vertex global position
			var vertex_local: Vector3 = mdt.get_vertex(i)
			var vertex_global: Vector3 = vertex_local * mesh_instance.global_transform.inverse()

			var curve_point_transform: Transform3D

			if last == true and is_equal_approx(vertex_local.z, min_z):
				curve_point_transform = path.curve.sample_baked_with_rotation(path.curve.get_baked_length())
			else:
				var closest_offset: float = path.curve.get_closest_offset(vertex_global)
				curve_point_transform = path.curve.sample_baked_with_rotation(closest_offset, false, true)
#
			var normal: Vector3 = mdt.get_vertex(i).x * curve_point_transform.basis.x
			var binormal: Vector3 = mdt.get_vertex(i).y * curve_point_transform.basis.y

			var new_pos: Vector3 =  curve_point_transform.origin + normal + binormal

			mdt.set_vertex(i, new_pos * mesh_instance.global_transform)

		array_mesh.clear_surfaces()
		mdt.commit_to_surface(array_mesh)
		mesh_instance.mesh = array_mesh

		mesh_instance.create_trimesh_collision()

func _prepare_mesh(mesh_instance: MeshInstance3D) -> MeshDataTool:
		if not mesh_instance is MeshInstance3D:
			push_warning("Skipping a deformation target that is not a MeshInstance3D: " + str(mesh_instance.name))
			return null

		if mesh_instance.mesh == null:
			push_warning("MeshInstance3D has no mesh: " + str(mesh_instance.name))
			return null

		# Create an ArrayMesh from the MeshInstance mesh and set it to a MeshDataTool for processing
		array_mesh = ArrayMesh.new()
		var surface_arrays: Array = mesh_instance.mesh.surface_get_arrays(0)
		if surface_arrays.is_empty():
			push_warning("MeshInstance3D has no valid surface arrays: " + str(mesh_instance.name))
			return null

		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_instance.mesh.surface_get_arrays(0))
		var mdt: MeshDataTool = MeshDataTool.new()

		if mdt.create_from_surface(array_mesh, 0) != OK:
			push_warning("Failed to create MeshDataTool from surface: " + str(mesh_instance.name))
			return null

		return mdt
