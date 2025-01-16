@tool
class_name SectionLoader
extends Node

@onready var mesh_deformer: MeshDeformer = %MeshDeformer

func load_section(section: Section, loader: PartLoader, path: Path3D) -> void:
	if not is_instance_valid(section):
		printerr("Not is_instance_valid : {}".format(section, "{}"))
		return

	#FIXED SECTION
	if section.fixed == true:
		#JUNCTIONS
		_load_junctions(section, loader, path)
		if is_instance_valid(section.fixed_scene) :
			var fixed_part: Part = section.fixed_scene.instantiate()
			loader.load_part(fixed_part, path)
		else:
			printerr("No PackedScene set")

	else:
		if section.pool_directory != null:
			var pool_parts: Array[PackedScene] = _load_pool(section.pool_directory)
			var section_length: float = 0
			for x: int in pool_parts.size():
				#JUNCTIONS
				_load_junctions(section, loader, path)
				if section_length < section.length :
					var part_scene: PackedScene = pool_parts.pop_front()
					var part: Part = part_scene.instantiate()
					var part_length: float = loader.load_part(part, path)
					section_length += part_length
				else:
					break



func _load_junctions(section: Section, loader: PartLoader, path: Path3D) -> void:
	var junction_path_points: Array[int] = []

	if section.junctions_directory != null:
		var length: float = 0

		var junction_scenes: Array[PackedScene] = _load_pool(section.junctions_directory)
		var junction_parts: Array[Part] = []
		var starting_point: int = path.curve.point_count

		while length <= section.junctions_length:
			var junction_scene: PackedScene = junction_scenes.pick_random()
			var junction_part: Part = junction_scene.instantiate()
			junction_parts.append(junction_part)
			var junction_length: float = loader.load_part(junction_part, path)
			length += junction_length

		var junction_point_count: int = path.curve.point_count - starting_point

		for i: int in junction_point_count:
			junction_path_points.append(starting_point + i)

		_deform_path(section, path, junction_path_points)
		_deform_meshes(junction_parts, path)



func _deform_path(section: Section, path: Path3D, points: Array[int]) -> void:
	for i: int in points.size():
		if i < 2 or i > points.size() - 2:
			continue

		var init_position: Vector3 = path.curve.get_point_position(points[i])

		var x: float = randf_range(-section.x_delta, section.x_delta)
		var y: float = randf_range(-section.hills_range, section.hills_range)

		var positions_sum: Vector3 = Vector3(x, y, 0) + init_position

		path.curve.set_point_position(points[i], positions_sum)

		_smooth_path(section, path, points[i] -1, true, true)

	_smooth_path(section, path, points[0], false, true)
	_smooth_path(section, path, points[points.size() - 2], true, false)


func _smooth_path(section: Section, path: Path3D, point: int, point_in: bool, point_out: bool) -> void:
		var prev_point: Vector3 = path.curve.get_point_position(point - 1)
		var p_point: Vector3 = path.curve.get_point_position(point)
		var next_point: Vector3 = path.curve.get_point_position(point +1)

		var direction_a: Vector3 = (p_point - prev_point)
		var direction_b: Vector3 = (next_point - p_point)

		var tangent_at_p: Vector3 = (direction_a + direction_b)

		tangent_at_p = tangent_at_p.limit_length(direction_a.length() * section.smoothing_ratio)
		tangent_at_p = tangent_at_p.limit_length(direction_b.length() * section.smoothing_ratio)

		if point_in == true:
			path.curve.set_point_in(point, -tangent_at_p)
		if point_out == true:
			path.curve.set_point_out(point, tangent_at_p)

func _deform_meshes(parts: Array[Part], path: Path3D) -> void:
	for part: Part in parts:
		var meshes: Array[MeshInstance3D]
		for child: Node in Utilities.get_all_children(part):
			if child is MeshInstance3D:
				meshes.append(child)
		if parts[parts.size() - 1] == part:
			mesh_deformer.deform_mesh(meshes, path, true)
		else:
			mesh_deformer.deform_mesh(meshes, path, false)

func _load_pool(pool_dir: String) -> Array[PackedScene]:
	var parts_paths: PackedStringArray = DirAccess.get_files_at(pool_dir)
	var _parts: Array[PackedScene] = []

	for filename: String in parts_paths:
		var part_resource: PackedScene = load(pool_dir + "/" + filename)
		_parts.append(part_resource)

	_parts.shuffle()

	return _parts
