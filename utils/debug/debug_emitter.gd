class_name DebugEmitter
extends Node

@export var level: DebugUi.Levels
@export var nodes: Dictionary
@export var player: Player

func _ready() -> void:
	DebugUi.current_level = level
	for i: String in nodes.keys():
		var path: NodePath = nodes[i]
		DebugUi.set(i, get_node(path))
	player.reached_exit.connect(_on_player_reached_exit)

func _on_player_reached_exit() -> void:
	DebugUi.current_level = DebugUi.Levels.NONE
