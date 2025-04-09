class_name Seal
extends Area3D

signal broke

func _ready() -> void:
	broke.connect(_break)
	for child: Node in Utilities.get_all_children(self):
		child.add_to_group("gameplay_elements")

func _break(direction: Vector3) -> void:
	pass
