@tool
class_name LevelGenerator
extends Path3D

@export var level: Level
@export var deform_level: bool = true

var dirty: bool = false

@onready var level_creator: Node = %LevelCreator

func _process(delta: float) -> void:
	if is_instance_valid(level):
		if not dirty:
			dirty = true
			level_creator.create_level(level.level_resource, self, deform_level)


func regenerate_level():
	for child in Utilities.get_all_children(self):
		if child is Part:
			child.queue_free()
	dirty = false


func _on_visibility_changed() -> void:
	if visible == true:
		regenerate_level()
