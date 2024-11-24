@tool
@icon("res://addons/csg_toolbox/icons/PartTester.svg")
class_name PartTester
extends Node3D

@export var part: PackedScene:
	set(value):
		part = value
		if is_inside_tree():
			part_generator.call_deferred("regenerate_part")
@export var part_scale: int = 1:
	set(value):
		part_scale = value
		if is_inside_tree():
			part_generator.call_deferred("regenerate_part")

@export var starting_distance: int = 100:
	set(value):
		starting_distance = value
		if is_inside_tree():
			part_generator.call_deferred("regenerate_part")

@onready var part_generator: PartGenerator = %PartGenerator
@onready var player: Player = %Player

func _ready() -> void:
	if not Engine.is_editor_hint():
		player.exited_path.connect(part_generator._on_player_exited_path)
