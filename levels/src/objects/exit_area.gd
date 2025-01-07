@tool
@icon("res://addons/csg_toolbox/icons/ExitArea.svg")
class_name ExitArea
extends Area3D

func _ready() -> void:
	self.name = "ExitArea"
	if get_children() == []:
		var collision_box: CollisionShape3D = CollisionShape3D.new()
		collision_box.shape = BoxShape3D.new()
		collision_box.name = "ExitCollision"
		add_child(collision_box)
		collision_box.owner = get_tree().edited_scene_root
