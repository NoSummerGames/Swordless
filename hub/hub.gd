class_name Hub
extends Node3D

signal level_entered

@export var hub_ui: HubUI


func _on_child_entered_tree(node: Node) -> void:
	if node is HubPassage:
		(node as HubPassage).interacted.connect(hub_ui._on_passage_interacted)
		(node as HubPassage).passage_entered.connect(_on_passage_entered)

# TODO variation still missing
func _on_passage_entered(level: PackedScene) -> void:
	# TODO variation still missing
	emit_signal("level_entered", level)






