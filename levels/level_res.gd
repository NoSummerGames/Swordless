class_name LevelResource
extends CustomResource

signal level_updated

@export var name: String = ""
@export_file("*.tscn") var level_scene: String
@export_multiline var description: String
@export var baseline: String = ""
@export var variations: Array[LevelVariationResource]

var discovered: bool = false
