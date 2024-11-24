@tool
extends Node

var junction_path_points: Array[int]

func load_section(section: Section, loader: Node, path: Path3D):
	if not is_instance_valid(section):
		printerr("Not is_instance_valid : {}".format(section, "{}"))
		return

	#FIXED SECTION
	if section.fixed == true:
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
					var part_length = loader.load_part(part, path)
					section_length += part_length
				else:
					continue

func _load_junctions(section: Section, loader: Node, path: Path3D):
	if section.junctions_directory != null:
		var junction_parts: Array[PackedScene] = _load_pool(section.junctions_directory)
		var length: float = 0
		var junctions: Array[Part] = []
		var starting_point: int = path.curve.point_count

		while length <= section.junctions_length:
			var junction_scene: PackedScene = junction_parts.pick_random()
			var junction_part: Part = junction_scene.instantiate()
			junctions.append(junction_part)

			var junction_length = loader.load_part(junction_part, path)
			length += junction_length

		var junction_point_count: int = path.curve.point_count - starting_point

		for i in junction_point_count - 1:
			junction_path_points.append(starting_point + i)


func _load_pool(pool_dir: String) -> Array[PackedScene]:
	var parts_paths: PackedStringArray = DirAccess.get_files_at(pool_dir)
	var _parts: Array[PackedScene] = []

	for filename: String in parts_paths:
		var part_resource: PackedScene = load(pool_dir + "/" + filename)
		_parts.append(part_resource)

	_parts.shuffle()

	return _parts
