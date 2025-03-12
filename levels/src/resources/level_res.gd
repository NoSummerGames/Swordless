@tool
class_name LevelResource
extends Resource

@export_group("Level")
@export var entry_scene: PackedScene
@export var sections: Array[Section]
@export var exit_scene: PackedScene

@export_group("Rules")
@export var level_rules: GameRules
