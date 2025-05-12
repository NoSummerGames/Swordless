@tool
class_name LevelResource
extends Resource

@export_group("Level")
@export var entry_scene: PackedScene
@export var sections: Array[Section]
@export var exit_scene: PackedScene

@export_group("Rules")
@export var level_rules: GameRules

@export_group("Infos")
@export var name: StringName = ""
@export_multiline var description: String
@export var classic_level: StringName
@export var blackened_level: StringName

var discovered: bool = false
var blackened_unlocked: bool = false
var classic_finished: bool = false
var blackened_finished: bool = false
