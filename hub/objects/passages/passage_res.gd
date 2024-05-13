class_name PassageResource
extends CustomResource

signal level_updated

@export_group("Infos")
@export var name: StringName = ""
@export_multiline var description: String
@export var classic_level: StringName
@export var classic_level_scene: PackedScene
@export var blackened_level: StringName
@export var blackened_level_scene: PackedScene

var discovered: bool = false
var blackened_unlocked: bool = false
var classic_finished: bool = false
var blackened_finished: bool = false
