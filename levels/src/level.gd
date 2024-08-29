class_name Level
extends Node3D

signal level_finished

@export var level_resource: LevelResource
@export var level_generator: LevelGenerator

func _ready() -> void:
	level_generator.exit_area_found.connect(_on_exit_area_found)

func _on_exit_area_found(area: ExitArea) -> void:
	area.exit_area_entered.connect(level_finished.emit)
