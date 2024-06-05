@tool
class_name ExitArea
extends Area3D

signal exit_area_entered

func _ready() -> void:
	if get_children() == []:
		var collision_box = CollisionShape3D.new()
		collision_box.shape = BoxShape3D.new()
		collision_box.name = "ExitCollision"
		add_child(collision_box)
		collision_box.owner = get_tree().edited_scene_root
	if not body_entered.is_connected(_on_self_body_entered):
		body_entered.connect(_on_self_body_entered)
		
func _on_self_body_entered(body: Node3D):
	if body is Player:
		emit_signal("exit_area_entered")
