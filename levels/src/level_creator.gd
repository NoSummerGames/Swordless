@tool
extends Node

var meshes: Array[MeshInstance3D]

@onready var part_loader = %PartLoader
@onready var section_loader = %SectionLoader
@onready var mesh_deformer = %MeshDeformer
@onready var smooth_path = Path3D.new()

func create_level(level: LevelResource, path: Path3D, deform_level: bool):
	meshes.clear()
	section_loader.junction_path_points.clear()

	path.curve = Curve3D.new()
	path.curve.add_point(Vector3.BACK)
	path.curve.add_point(Vector3.ZERO)

	# Load EntryScene
	if is_instance_valid(level.entry_scene):
		var entry_part = level.entry_scene.instantiate()
		part_loader.load_part(entry_part, path)

	# Load sections
	for section in level.sections:
		section_loader.load_section(section, part_loader, path)

	# Load ExitScene
	if is_instance_valid(level.exit_scene):
		var exit_part = level.exit_scene.instantiate()
		part_loader.load_part(exit_part, path)

	if deform_level == false:
		return



	await get_tree().process_frame
	for child in Utilities.get_all_children(get_parent()):
		if child is MeshInstance3D:
			meshes.append(child)

	_randomize_point(path, section_loader.junction_path_points)
	for x in section_loader.junction_path_points.size():
		var i = section_loader.junction_path_points[x]
		if i < 2:
			continue
		_smooth_path(path, i, true, true)
		if section_loader.junction_path_points[x - 1] != i - 1:
			_smooth_path(path, i - 1, false, true)

		if not x >= section_loader.junction_path_points.size() -1:
			if section_loader.junction_path_points[x + 1] != i + 1 :
				_smooth_path(path, i + 1, true, false)

	mesh_deformer.deform_mesh(meshes, path)

func _randomize_point(path: Path3D, points):
	var previous_sum: Vector3 = Vector3.ZERO
	for i in path.curve.point_count :
		if i < 2:
			continue
		var previous_position = path.curve.get_point_position(i - 1)
		var position = path.curve.get_point_position(i)
		var distance = previous_position.distance_to(position)

		var positions_sum: Vector3 = Vector3.ZERO
		if i in section_loader.junction_path_points:
			var x: float = randf_range(-0.5,0.5)
			var y: float = randf_range(-0.1, 0.1)
			positions_sum = Vector3(x, y, 0) * 2
		else:
			pass
		previous_sum += positions_sum

		path.curve.set_point_position(i, positions_sum + position + previous_sum)

func _smooth_path(path: Path3D, point: int, point_in: bool, point_out: bool):
		var prev_point: Vector3 = path.curve.get_point_position(point - 1)
		var p_point: Vector3 = path.curve.get_point_position(point)
		var next_point: Vector3 = path.curve.get_point_position(point +1)

		var direction_a: Vector3 = (p_point - prev_point).normalized()
		var direction_b: Vector3 = (next_point - p_point).normalized()

		var tangent_at_p: Vector3 = (direction_a + direction_b).normalized()

		tangent_at_p = tangent_at_p.limit_length((p_point - prev_point).length())
		tangent_at_p = tangent_at_p.limit_length((next_point - p_point).length())
		if point_in == true:
			path.curve.set_point_in(point, -tangent_at_p)
		if point_out == true:
			path.curve.set_point_out(point, tangent_at_p)
