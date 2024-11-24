@tool
class_name LevelGenerator
extends Path3D

@export var level: Level
@export var deform_level: bool = true

var dirty: bool = false

@onready var level_creator: LevelCreator = %LevelCreator

func _process(_delta: float) -> void:
	if is_instance_valid(level):
		if not dirty:
			dirty = true
			level_creator.create_level(level.level_resource, self, deform_level)


func regenerate_level() -> void:
	for child: Node in Utilities.get_all_children(self):
		if child is Part:
			child.queue_free()
	dirty = false


func _on_visibility_changed() -> void:
	if visible == true:
		regenerate_level()
