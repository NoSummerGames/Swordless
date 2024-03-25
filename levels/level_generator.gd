@tool
extends Node3D

@export var level : LevelVariation
@export var starting_distance: int = 10
@export var path: Path3D

var curve: Curve3D
var dirty: bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not dirty:
		call_deferred("_create_level", level.sections)

func _create_level(sections: Array[Section]) -> void:
	# Add a new curve to the level path
	curve = Curve3D.new()
	path.curve = curve
	load_entry_scene()

	for section: Section in sections:
		# Check if the next section is fixed or is a pool of objects
		if section.fixed == true:
			var part: Part = section.fixed_scene.instantiate()
			load_part(part, section)

		else:
			var initial_length: float = curve.get_baked_length()
			var parts_paths: PackedStringArray = DirAccess.get_files_at(section.pool_dir)
			var parts: Array[Part] = _load(parts_paths, section.pool_dir)
			parts.shuffle()

			for x: int in parts.size():
				var condition: float = curve.get_baked_length() - initial_length
				if condition > section.length:
					break
				var part: Part = parts.pop_front()
				load_part(part, section)

	dirty = true

func load_entry_scene() -> void:
	# Load entry scene
	if level.entry_scene == null:
		level.entry_scene = EntryScene.new()

	if not level.entry_scene.fixed_scene == null:
		var entry_scene: Part = level.entry_scene.fixed_scene.instantiate()
		add_child(entry_scene)
		entry_scene.scale *= level.entry_scene.scale

		# Assert that the entry_scene has a path
		assert(entry_scene.part_path != null, "The entry_scene path hasn't been set.")

		#Set its path points as the curve starting points
		var b_curve: Curve3D = entry_scene.part_path.curve
		for i in b_curve.point_count:
			curve.add_point(b_curve.get_point_position(i) * level.entry_scene.scale)
	else:
		curve.add_point(Vector3.ZERO)
		curve.add_point(Vector3.FORWARD * level.entry_scene.scale)
		curve.add_point(Vector3.FORWARD * 2 * level.entry_scene.scale)
	#Pursue path generation
	add_segment(curve, starting_distance, level.entry_scene)

func load_part(_part: Part, _section: Section) -> void:
	add_child(_part)
	_part.scale *= _section.scale
	# Get lastest two points in the curve and the direction between them
	var last_position: Vector3 = path.curve.get_point_position(path.curve.point_count -1)
	var before_last_postion: Vector3 = path.curve.get_point_position(path.curve.point_count -2)
	var direction: Vector3 = before_last_postion.direction_to(last_position)

	# Add a forward point in that direction to prevent placing the part in an angle
	curve.add_point(last_position  + direction * (randi_range(_section.parts_distance.x, _section.parts_distance.y) * _section.scale))

	# Rotate the part so that it matches the path direction
	_part.global_position = before_last_postion
	_part.look_at(last_position, Vector3.UP, false)

	# Set its final position at the end of the curve
	last_position = path.curve.get_point_position(path.curve.point_count -1)
	_part.global_position = last_position

	# Add local object path points - if any - to the level curve
	if _part.has_path == true:
		var b_curve: Curve3D = _part.part_path.curve
		if b_curve.get_point_position(0) != Vector3.ZERO:
			curve.add_point(_part.to_global(b_curve.get_point_position(0)))
		for i: int in b_curve.point_count -1:
			curve.add_point(_part.to_global(b_curve.get_point_position(i +1)))

	# Pursue path generation
	add_segment(curve, _section.max_segments, _section)


func add_segment(_curve: Curve3D, count: int, _section: Section) -> void:
	# Add an empty path segment forward so that there isn't an angle just behind a part
	var last_position: Vector3 = path.curve.get_point_position(path.curve.point_count -1)
	var before_last_postion: Vector3 = path.curve.get_point_position(path.curve.point_count -2)
	var direction: Vector3 = before_last_postion.direction_to(last_position)

	curve.add_point(last_position  + direction * (randi_range(_section.parts_distance.x, _section.parts_distance.y) * _section.scale))

	# Add random segments afterwards according to the section parameters
	for n: int in count:
		last_position = path.curve.get_point_position(path.curve.point_count -1)
		var x: float = randf_range(-_section.x_delta, _section.x_delta)
		var y: float = randf_range(_section.y_delta.x, _section.y_delta.y)
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

#func _get_part_size(part: Part):
	#var scene_children = get_all_chidren(part)
	#var bounding_boxes: Array[AABB]
	#for child in scene_children:
		#if child is VisualInstance3D:
			#bounding_boxes.append(child.get_aabb())
	#if not bounding_boxes.is_empty():
		#var merged_aabb: AABB = bounding_boxes[0]
		#for aabb in bounding_boxes:
			#merged_aabb.merge(aabb)
		#return merged_aabb
	#else: return AABB()

#func set_player_path():
	#if (i > 1) and (i < (points_number - 1)):
	#var previous_point = _curve.get_point_position(i - 2)
	#var p_point = _curve.get_point_position(i - 1)
	#var next_point = _curve.get_point_position(i)
#
	#var tangent_at_p = ((p_point - previous_point).normalized() + (next_point - p_point).normalized()) * curve_smoothing
#
	#_curve.set_point_in(i- 1, -tangent_at_p)
	#_curve.set_point_out(i- 1, tangent_at_p)

func get_all_chidren(node: Node) -> Array[Node]:
	var nodes : Array[Node] = []
	var _get_all_children: Callable = func(_node: Node, lambda: Callable) -> void:
		for child: Node in _node.get_children():
			if child.get_child_count() > 0:
				nodes.append(child)
				lambda.call(child, lambda)
			else:
				nodes.append(node)
	if nodes.is_empty():
		_get_all_children.call(node, _get_all_children)
	return nodes

func _on_button_pressed() -> void:
	dirty = false
	for child: Node in get_children():
		child.queue_free()


func _on_visibility_changed() -> void:
	dirty = false
	for child: Node in get_children():
		child.queue_free()
