@tool
class_name PartGenerator
extends Path3D

@export var part_tester: PartTester

var dirty: bool = false

var parts: Array[Part] = []

func _process(delta: float) -> void:
	if not dirty :
		if part_tester != null and part_tester.part != null:
			_create_level(part_tester.part)

func _create_level(part_scene: PackedScene):
	curve = Curve3D.new()
	curve.add_point(Vector3.BACK)
	curve.add_point(Vector3.ZERO)

	var meshes: Array

	if is_instance_valid(part_tester.starting_block_scene):
		for i in part_tester.starting_blocks:
			meshes.append(await load_part(part_tester.starting_block_scene))

	meshes.append(await load_part(part_scene))

	for i in meshes:
		for child: Node in Utilities.get_all_children(i):
			if child is MeshInstance3D:
				child.create_trimesh_collision()


func load_part(_part: PackedScene):
	var part: Part = _part.instantiate()
	# Important order between above an below lines ! The part must be instantiated before awaiting
	await get_tree().process_frame

	add_child(part)
	parts.append(part)

	var last_position: Vector3 = curve.get_point_position(curve.point_count -1)
	# Set its final position at the end of the curve
	part.global_position = last_position
	part.scale *= part_tester.part_scale

	# Add local object path points - if any - to the level curve
	if part.has_path == true:
		var b_curve = part.part_path.curve
		if b_curve.get_point_position(0) != Vector3.ZERO:
			curve.add_point(part.to_global(b_curve.get_point_position(0)))
		for i in b_curve.point_count -1:
			curve.add_point(part.to_global(b_curve.get_point_position(i +1)))
	else:
		# Get part AABB to add next point at the end of the part
		var part_aabb = _calculate_spatial_bounds(part, false)
		#part.global_position.z -= (part_aabb.position.z + part_aabb.size.z)
		curve.add_point(last_position + Vector3.FORWARD * part_aabb.size.z)

	dirty = true
	return part


func _calculate_spatial_bounds(parent : Node3D, exclude_top_level_transform: bool) -> AABB:
	var bounds : AABB = AABB()
	if parent is VisualInstance3D:
		var _parent: VisualInstance3D = parent
		bounds = _parent.get_aabb();

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



func regenerate_part() -> void:
	if not Engine.is_editor_hint():
		pass
	else:
		for part in parts:
			part.queue_free()
		parts.clear()
		dirty = false

func _on_visibility_changed() -> void:
	regenerate_part()
