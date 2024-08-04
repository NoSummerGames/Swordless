@tool
class_name Part
extends Node3D

var path_id: int = 0


@export var has_path: bool:
	set(value):
		has_path = value
		if not is_inside_tree():
			return
		if value == true:
			if not is_instance_valid(part_path):
				part_path = Path3D.new()
				add_child(part_path)
				part_path.set_owner(self)
				var curve = Curve3D.new()
				curve.add_point(Vector3.ZERO)
				curve.add_point(Vector3.FORWARD)
				part_path.curve = curve
		else:
			if part_path != null:
				part_path.queue_free()
		notify_property_list_changed()

@export var part_path: Path3D

@export var difficulty : Data.PartDifficulties

@export_multiline var notes: String = ""

func _validate_property(property: Dictionary) -> void:
	if property.name == "part_path" and has_path == false:
		property.usage = PROPERTY_USAGE_READ_ONLY
