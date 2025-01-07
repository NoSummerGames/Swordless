class_name AbstractWorldLoader
extends Node

signal level_loading
signal level_loaded

@export var fade_player: AnimationPlayer

var current_level: Node3D = null:
	set(value):
		current_level = value
		_on_level_changed(current_level)

var current_scene: PackedScene

func load_scene(scene: PackedScene, skip_transition: bool = false) -> void:
	level_loading.emit()

	if skip_transition == false:
		fade_player.play("fade_in")
		await fade_player.animation_finished

	call_deferred("_load_scene_deffered", scene, skip_transition)

func _load_scene_deffered(scene: PackedScene, skip_transition: bool = false) -> void:
	if get_tree().paused == true:
		get_tree(). paused = false

	# It is now safe to remove the current scene
	if current_level != null:
		current_level.free()

	# Instance the new scene.
	current_scene = scene
	current_level = scene.instantiate()

	# Add it to the main scene
	add_child(current_level)

	if skip_transition == false:
		fade_player.play("fade_out")
		await fade_player.animation_finished

	level_loaded.emit()


func _on_level_changed(_level: Node3D) -> void:
	pass
