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
@export var starting_blocks: int = 5:
	set(value):
		starting_blocks = value
		if is_inside_tree():
			%PartGenerator.call_deferred("regenerate_part")

@export var starting_block_scene: PackedScene:
	set(value):
		if value == null:
			starting_block_scene = load("res://addons/csg_toolbox/starting_block.tscn")
			if is_inside_tree():
				%PartGenerator.call_deferred("regenerate_part")
		else:
			starting_block_scene = value
			if is_inside_tree():
				%PartGenerator.call_deferred("regenerate_part")
@export var exit_restart_time: float = 0.5:
	set(value):
		exit_restart_time = value
		if is_inside_tree():
			%PartGenerator.call_deferred("regenerate_part")

@onready var player: Player = %Player

func _ready() -> void:
	editor_state_changed.connect(print.bind("changed"))

	if starting_block_scene == null:
		starting_block_scene = load("res://addons/csg_toolbox/starting_block.tscn")

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
