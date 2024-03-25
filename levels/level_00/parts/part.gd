@tool
class_name Part
extends Node3D

var path_id: int = 0

@export var has_path: bool = false:
	set(value):
		if value == true and value != has_path:
			var path = Path3D.new()
			add_child(path)
			path.set_owner(self)
			var curve = Curve3D.new()
			curve.add_point(Vector3.ZERO)
			curve.add_point(Vector3.FORWARD)
			path.curve = curve
			part_path = path
			has_path = value
		elif value == true:
			for child in get_children():
				if child is Path3D:
					part_path = child
		else:
			for child in get_children():
				if child is Path3D:
					child.queue_free()
			has_path = value
		notify_property_list_changed()

@export var part_path: Path3D

@export var difficulty : Data.PartDifficulties

func _validate_property(property: Dictionary) -> void:
	if property.name == "part_path" and has_path == false:
		property.usage = PROPERTY_USAGE_READ_ONLY
