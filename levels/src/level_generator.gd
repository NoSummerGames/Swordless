@tool
class_name LevelGenerator
extends Path3D

@export var accent_material: Material
@export var default_material: Material

@export var level: Level

@onready var level_creator: LevelCreator = %LevelCreator

func _ready() -> void:
	if not Engine.is_editor_hint():
		_create_level()


func _create_level() -> void:
	if is_instance_valid(level):
		DebugSettings.reset_parts_list()
		level_creator.create_level(level.level_resource, self)



func regenerate_level() -> void:
	for child: Node in Utilities.get_all_children(self):
		if child is Part:
			child.queue_free()
	_create_level()
