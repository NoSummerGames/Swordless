class_name DebugEmitter
extends Node

@export var level: DebugUi.Levels
@export var nodes: Dictionary

func _ready() -> void:
	DebugUi.current_level = level
	for i: String in nodes.keys():
		var path: NodePath = nodes[i]
		DebugUi.set(i, get_node(path))

func _exit_tree() -> void:
	DebugUi.current_level = DebugUi.Levels.NONE
