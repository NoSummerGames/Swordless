@tool
extends Path3D

@export var level: Node3D

var dirty: bool = false

var parts = []

func _ready() -> void:
	# Add a new curve to the level path
	curve = Curve3D.new()
	curve.add_point(Vector3.ZERO)
	curve.add_point(Vector3.FORWARD)

func _process(delta: float) -> void:
	if not dirty and level != null and level.part != null:
		call_deferred("_create_level", level.part)

func _create_level(_part: PackedScene):
	var part: Part = _part.instantiate()
	call_deferred("load_part", part)
	dirty = true

func load_part(_part: Part):
	add_child(_part)
	parts.append(_part)
	_part.scale *= level.part_scale
	# Get lastest two points in the curve and the direction between them
	var last_position = curve.get_point_position(curve.point_count -1)
	var before_last_postion = curve.get_point_position(curve.point_count -2)
	var direction = before_last_postion.direction_to(last_position)

	# Add a forward point in that direction to prevent placing the part in an angle
	curve.add_point(last_position  + direction * level.starting_distance * level.part_scale)

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
		curve.add_point(last_position + (direction * part_aabb.size.z) * level.part_scale)


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

func _on_visibility_changed() -> void:
	regenerate_part()

func _on_player_exited_path():
	for part in parts:
		part.queue_free()
	parts.clear()
	dirty = false

func _on_player_restarted():
	regenerate_part()

func regenerate_part() -> void:
	for part in parts:
		part.queue_free()
	parts.clear()
	# Add a new curve to the level path
	curve = Curve3D.new()
	curve.add_point(Vector3.ZERO)
	curve.add_point(Vector3.FORWARD)
	dirty = false
	
