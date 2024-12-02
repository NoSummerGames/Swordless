@tool
@icon("res://addons/csg_toolbox/icons/PartTester.svg")
class_name PartTester
extends Node3D


@export_category("Part")
@export var part: PackedScene:
	set(value):
		part = value
		if is_inside_tree():
			%PartGenerator.call_deferred("regenerate_part")

@export var part_scale: int = 1:
	set(value):
		part_scale = value
		if is_inside_tree():
			%PartGenerator.call_deferred("regenerate_part")

@export_category("Misc")
@export var starting_blocks: int = 5
@export var starting_block_scene: PackedScene
@export var exit_restart_time: float = 0.5

@onready var player: Player = %Player

func _ready() -> void:
	if not Engine.is_editor_hint():
		player.exited_path.connect(_on_player_exited_path)

func _on_player_exited_path():
	var timer: Timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = exit_restart_time
	add_child(timer)
	timer.start()
	await timer.timeout
	if is_inside_tree():
		%PartGenerator.call_deferred("regenerate_part")
