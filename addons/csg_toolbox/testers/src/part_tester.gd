@tool
@icon("res://addons/csg_toolbox/icons/PartTester.svg")
extends Node3D

@export var part: PackedScene:
	set(value):
		part = value
		if is_inside_tree():
			$PartGenerator.call_deferred("regenerate_part")
@export var part_scale: int = 1:
	set(value):
		part_scale = value
		if is_inside_tree():
			$PartGenerator.call_deferred("regenerate_part")

@export var starting_distance: int = 100:
	set(value):
		starting_distance = value
		if is_inside_tree():
			$PartGenerator.call_deferred("regenerate_part")

func _ready() -> void:
	if not Engine.is_editor_hint():
		$Player.exited_path.connect($PartGenerator._on_player_exited_path)
		$Player.restarted.connect($PartGenerator._on_player_restarted)


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed("start"):
			$Player.global_transform = Transform3D.IDENTITY
			$Player.emit_signal("restarted")
