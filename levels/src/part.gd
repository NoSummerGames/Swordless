@tool
class_name Part
extends Node3D

signal combo_completed

var path_id: int = 0
var seal_count: int = 0
var broken_seal_count: int = 0

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
				var curve: Curve3D = Curve3D.new()
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

func _ready() -> void:
	if not Engine.is_editor_hint():
		_connect_seals()

		# HACK Make .blend child local
		for child: Node in get_children():
			if child is Node3D and not child.is_in_group("gameplay_elements"):
				for blend_child: Node in child.get_children():
					blend_child.reparent(self)

func _validate_property(property: Dictionary) -> void:
	if property.name == "part_path" and has_path == false:
		property.usage = PROPERTY_USAGE_READ_ONLY

func _on_seal_broke(direction: Vector3) -> void:
	broken_seal_count += 1
	if broken_seal_count == seal_count:
		combo_completed.emit()

func _connect_seals() -> void:
	for child in Utilities.get_all_children(self):
		if child is Seal:
			seal_count += 1
			var seal: Seal = child
			seal.broke.connect(_on_seal_broke)
