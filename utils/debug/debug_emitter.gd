class_name DebugEmitter
extends Node

@export var level: DebugUi.Levels
@export var nodes: Dictionary

func _ready() -> void:
	DebugUi.current_level = level
	for i in nodes.keys():
		DebugUi.set(i, get_node(nodes[i]))

func _exit_tree() -> void:
	DebugUi.current_level = DebugUi.Levels.NONE
