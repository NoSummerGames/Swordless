class_name WorldLoader # Use as a base class to load_scene()
extends Node

signal level_loading
signal level_loaded

@export var hub_scene: PackedScene

var fade_player: AnimationPlayer

var current_scene: Node3D = null:
	set(value):
		current_scene = value
		if value is Hub:
			(value as Hub).level_entered.connect(_on_level_entered)
		if value is LevelVariation:
			(value as LevelVariation).level_entered.connect(_on_level_entered)

var current_packed_scene: PackedScene

func launch_game() -> void:
	load_scene(hub_scene)

func _on_level_entered(level: PackedScene) -> void:
	load_scene(level)

func _on_level_reloaded() -> void:
	load_scene(current_packed_scene)

func load_scene(scene: PackedScene) -> void:
	emit_signal("level_loading")
	await fade_player.animation_finished
	call_deferred("load_scene_deffered", scene)

func load_scene_deffered(scene: PackedScene) -> void:
	if get_tree().paused == true:
		get_tree(). paused = false

	# It is now safe to remove the current scene
	if current_scene != null:
		current_scene.free()

	# Instance the new scene.
	current_packed_scene = scene
	current_scene = scene.instantiate()

	# Add it to the main scene
	add_child(current_scene)
	emit_signal("level_loaded")
