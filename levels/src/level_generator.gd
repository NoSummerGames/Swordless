@tool
class_name LevelGenerator
extends Path3D

signal exit_area_found

@export var starting_distance: int = 10
@export var level: Level
#const DIR_TOLERANCE = 0.99

var dirty: bool = false
var parts: Array[Part] = []
var updated_length: float

func _process(_delta: float) -> void:
	if not dirty and is_instance_valid(level):
		_create_level(level.level_resource.sections)

func _create_level(sections: Array[Section]) -> void:
	# Add a new curve to the level path
	curve = Curve3D.new()
	curve.add_point(Vector3.ZERO)
	curve.add_point(Vector3.FORWARD)

	updated_length = 0

	if level.level_resource.entry_section == null:
		level.level_resource.entry_section = EntrySection.new()
	load_section(level.level_resource.entry_section)

	for section: Section in sections:
		if section != null:
			# Check if the next section is fixed or is a pool of objects
			if section.fixed == true:
				if section.fixed_scene != null :
					var part: Part = section.fixed_scene.instantiate()
					load_part(part, section)
				else:
					printerr("No PackedScene set (Section {})".format([sections.find(section) + 1], "{}"))

			else:
				if section.pool_dir != null:
					var parts_paths: PackedStringArray = DirAccess.get_files_at(section.pool_dir)
					var pool_parts: Array[Part] = _load(parts_paths, section.pool_dir)
					pool_parts.shuffle()

					for x: int in pool_parts.size():
						if updated_length < section.length :
							var part: Part = pool_parts.pop_front()
							load_part(part, section)

		updated_length = 0

	if level.level_resource.exit_section == null:
		level.level_resource.exit_section = ExitSection.new()
	load_section(level.level_resource.exit_section)

	#smooth_path()

	dirty = true


func load_section(_section: BaseSection) -> void:
	var _part: Part = _section.fixed_scene.instantiate()

	load_part(_part, _section)

	if _section is ExitSection:
		for child: Node3D in _part.get_children():
			if child is ExitArea:
				var exit_area: ExitArea = child
				exit_area.exit_area_entered.connect(exit_area_found.emit.bind(child))
				return

		printerr("No ExitArea found (ExitSection)")

	await get_tree().process_frame

	if _section is EntrySection:
		## Add an empty path segment forward so that there isn't an angle just behind a part
		var last_position: Vector3 = curve.get_point_position(curve.point_count -1)
		var before_last_postion: Vector3 = curve.get_point_position(curve.point_count -2)
		var direction: Vector3 = before_last_postion.direction_to(last_position)

		curve.add_point(last_position  + direction * level.level_resource.starting_distance * _section.scale)

func load_part(_part: Part, _section: BaseSection) -> void:
	await get_tree().process_frame

	if _section is Section:
		if updated_length > _section.length :
			return

	var curve_length: float = curve.get_baked_length()

	add_child(_part)
	parts.append(_part)
	_part.scale *= _section.scale

	# Get lastest two points in the curve and the direction between them
	var last_position: Vector3 = curve.get_point_position(curve.point_count -1)
	var before_last_postion: Vector3 = curve.get_point_position(curve.point_count -2)
	var direction: Vector3 = before_last_postion.direction_to(last_position)

	if _section is Section or _section is ExitSection:
		## Add a forward point in that direction to prevent placing the part in an angle
		curve.add_point(last_position  + direction * (randi_range(_section.parts_distance.x, _section.parts_distance.y) * _section.scale))

	# Rotate the part so that it matches the path direction
	_part.global_position = before_last_postion
	_part.look_at(last_position, Vector3.UP, false)

	# Set its final position at the end of the curve
	last_position = curve.get_point_position(curve.point_count -1)
	_part.global_position = last_position

	# Add local object path points - if any - to the level curve
	if _part.has_path == true:
		var part_curve: Curve3D = _part.part_path.curve
		if part_curve.get_point_position(0) != Vector3.ZERO:
			curve.add_point(_part.to_global(part_curve.get_point_position(0)))
		for i: int in part_curve.point_count -1:
			curve.add_point(_part.to_global(part_curve.get_point_position(i +1)))
	else:
		# Get part AABB to add next point at the end of the part
		var part_aabb: AABB = _calculate_spatial_bounds(_part, true)
		curve.add_point(last_position + (direction * part_aabb.size.z) * _section.scale)

	if _section is Section:
		# Pursue path generation
		add_segment(curve, _section.max_segments, _section)

	updated_length += curve.get_baked_length() - curve_length




func add_segment(_curve: Curve3D, count: int, _section: BaseSection) -> void:
	# Add an empty path segment forward so that there isn't an angle just behind a part
	var last_position: Vector3 = curve.get_point_position(curve.point_count -1)
	var before_last_postion: Vector3 = curve.get_point_position(curve.point_count -2)
	var direction: Vector3 = before_last_postion.direction_to(last_position)

	curve.add_point(last_position  + direction * (randi_range(_section.parts_distance.x, _section.parts_distance.y) * _section.scale))

	# Add random segments afterwards according to the section parameters
	for n: int  in count:
		last_position = curve.get_point_position(curve.point_count -1)
		var x: float = randf_range(-_section.x_delta, _section.x_delta)
		var y: float = randf_range(_section.low_delta, _section.high_delta)
		var z: float = -randf_range(_section.parts_distance.x, _section.parts_distance.y)
		var positions_sum: Vector3 = Vector3(x, y, z) * _section.scale + last_position
		curve.add_point(positions_sum)

func _load(paths: PackedStringArray, pool_dir: String) -> Array[Part]:
	var _parts: Array[Part] = []
	for filename: String in paths:
		var part_resource: PackedScene = load(pool_dir + "/" + filename)
		var part: Part = part_resource.instantiate()
		_parts.append(part)
	return _parts

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


func smooth_path() -> void:
	await get_tree().process_frame
#

	#var similar_points = []
#
	#for i in curve.point_count - 1:
		#if (i > 1) :
			#var prev_point = curve.get_point_position(i - 2)
			#var p_point = curve.get_point_position(i - 1)
			#var next_point = curve.get_point_position(i)
#
			#var direction_a = (p_point - prev_point).normalized()
			#var direction_b = (next_point - p_point).normalized()
#
			#if direction_a.dot(direction_b) > DIR_TOLERANCE:
				#similar_points.append(i)
#
	#var deleted = 0
#
	#for i in similar_points:
		#curve.remove_point(i - deleted)
		#deleted += 1

	for i: int in curve.point_count - 1:
		if (i > 1) :
			var prev_point: Vector3 = curve.get_point_position(i - 2)
			var p_point: Vector3 = curve.get_point_position(i - 1)
			var next_point: Vector3 = curve.get_point_position(i)

			var direction_a: Vector3 = (p_point - prev_point).normalized()
			var direction_b: Vector3 = (next_point - p_point).normalized()

			var tangent_at_p: Vector3 = (direction_a + direction_b).normalized()

			tangent_at_p = tangent_at_p.limit_length((p_point - prev_point).length())
			tangent_at_p = tangent_at_p.limit_length((next_point - p_point).length())
			curve.set_point_in(i - 1, -tangent_at_p)
			curve.set_point_out(i - 1, tangent_at_p)

func _on_visibility_changed() -> void:
	_regenerate_level()

func _regenerate_level() -> void:
	for part: Part in parts:
		part.queue_free()
	parts.clear()
	dirty = false
	print("level_regenerated")
