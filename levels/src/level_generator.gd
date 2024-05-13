@tool
class_name LevelGenerator
extends Path3D

@export var starting_distance: int = 10
@export var level: Level

var dirty: bool = false
var parts = []

func _process(delta: float) -> void:
	if not dirty and level.level_resource != null:
		call_deferred("_create_level", level.level_resource.sections)

func _create_level(sections: Array[Section]):
	# Add a new curve to the level path
	curve = Curve3D.new()
	load_entry_scene()

	for section in sections:
		if section != null:
			# Check if the next section is fixed or is a pool of objects
			if section.fixed == true:
				var part: Part = section.fixed_scene.instantiate()
				load_part(part, section)

			else:
				if section.pool_dir != null:
					var parts_paths: PackedStringArray = DirAccess.get_files_at(section.pool_dir)
					var parts: Array[Part] = _load(parts_paths, section.pool_dir)
					parts.shuffle()

					for x: int in parts.size():
						var part = parts.pop_front()
						call_deferred("load_part", part, section)
	#call_deferred("smooth_path")
	dirty = true

func load_entry_scene():
	# Load entry scene
	if level.level_resource.entry_scene == null:
		level.level_resource.entry_scene = EntryScene.new()

	if not level.level_resource.entry_scene.fixed_scene == null:
		var entry_scene: Part = level.level_resource.entry_scene.fixed_scene.instantiate()
		add_child(entry_scene)
		parts.append(entry_scene)
		entry_scene.scale *= level.level_resource.entry_scene.scale

		# Assert that the entry_scene has a path
		assert(entry_scene.part_path != null, "The entry_scene path hasn't been set.")

		#Set its path points as the curve starting points
		var b_curve: Curve3D = entry_scene.part_path.curve
		for i in b_curve.point_count:
			curve.add_point(b_curve.get_point_position(i) * level.level_resource.entry_scene.scale)
	else:
		curve.add_point(Vector3.ZERO)
		curve.add_point(Vector3.FORWARD * level.level_resource.entry_scene.scale)
		curve.add_point(Vector3.FORWARD * 2 * level.level_resource.entry_scene.scale)
	#Pursue path generation
	add_segment(curve, starting_distance, level.level_resource.entry_scene)

func load_part(_part: Part, _section):
	add_child(_part)
	parts.append(_part)
	_part.scale *= _section.scale
	# Get lastest two points in the curve and the direction between them
	var last_position = curve.get_point_position(curve.point_count -1)
	var before_last_postion = curve.get_point_position(curve.point_count -2)
	var direction = before_last_postion.direction_to(last_position)

	# Add a forward point in that direction to prevent placing the part in an angle
	curve.add_point(last_position  + direction * (randi_range(_section.parts_distance.x, _section.parts_distance.y) * _section.scale))

	# Rotate the part so that it matches the path direction
	_part.global_position = before_last_postion
	_part.look_at(last_position, Vector3.UP, false)

	# Set its final position at the end of the curve
	last_position = curve.get_point_position(curve.point_count -1)
	_part.global_position = last_position

	# Add local object path points - if any - to the level curve
	if _part.has_path == true:
		var b_curve = _part.part_path.curve
		if b_curve.get_point_position(0) != Vector3.ZERO:
			curve.add_point(_part.to_global(b_curve.get_point_position(0)))
		for i in b_curve.point_count -1:
			curve.add_point(_part.to_global(b_curve.get_point_position(i +1)))
	else:
		# Get part AABB to add next point at the end of the part
		var part_aabb = _calculate_spatial_bounds(_part, true)
		curve.add_point(last_position + (direction * part_aabb.size.z) * _section.scale)

	# Pursue path generation
	add_segment(curve, _section.max_segments, _section)


func add_segment(_curve: Curve3D, count: int, _section: Section):
	# Add an empty path segment forward so that there isn't an angle just behind a part
	var last_position = curve.get_point_position(curve.point_count -1)
	var before_last_postion = curve.get_point_position(curve.point_count -2)
	var direction = before_last_postion.direction_to(last_position)

	curve.add_point(last_position  + direction * (randi_range(_section.parts_distance.x, _section.parts_distance.y) * _section.scale))

	# Add random segments afterwards according to the section parameters
	for n in count:
		last_position = curve.get_point_position(curve.point_count -1)
		var x = randf_range(-_section.x_delta, _section.x_delta)
		var y = randf_range(_section.y_delta.x, _section.y_delta.y)
		var z = -randf_range(_section.parts_distance.x, _section.parts_distance.y)
		var positions_sum: Vector3 = Vector3(x, y, z) * _section.scale + last_position
		curve.add_point(positions_sum)

func _load(paths: PackedStringArray, pool_dir: String) -> Array[Part]:
	var _parts: Array[Part] = []
	for filename: String in paths:
		var part_resource: PackedScene = load(pool_dir + "/" + filename)
		var part: Part = part_resource.instantiate()
		_parts.append(part)
	return _parts

func _calculate_spatial_bounds(parent : Node, exclude_top_level_transform: bool) -> AABB:
	var bounds : AABB = AABB()
	if parent is VisualInstance3D:
		bounds = parent.get_aabb();

	for i in range(parent.get_child_count()):
		var child : Node = parent.get_child(i)
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

#func smooth_path():
	#var curve_smoothing = 2
	#for i in curve.point_count - 1:
		#if (i > 3) :
			#var previous_point = curve.get_point_position(i - 2)
			#var p_point = curve.get_point_position(i - 1)
			#var next_point = curve.get_point_position(i)
#
			#var tangent_at_p = ((p_point - previous_point).normalized() + (next_point - p_point).normalized()) * curve_smoothing
#
			#curve.set_point_in(i- 1, -tangent_at_p)
			#curve.set_point_out(i- 1, tangent_at_p)

func _on_visibility_changed() -> void:
	_regenerate_level()

func _regenerate_level() -> void:
	dirty = false
	for part in parts:
		part.queue_free()
	parts.clear()
	print("level_regenerated")
