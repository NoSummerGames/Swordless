class_name WorldLoader # Use as a base class to load_scene()
extends Node

signal level_loading
signal level_loaded

@export var title_scene: PackedScene
@export var hub_scene: PackedScene

var fade_player: AnimationPlayer

var current_scene: Node3D = null:
	set(value):
		current_scene = value
		if value is Hub:
			(value as Hub).level_entered.connect(_on_level_entered)
		if value is Level:
			(value as Level).level_entered.connect(_on_level_entered)
			(value as Level).level_finished.connect(_on_level_finished)

var current_packed_scene: PackedScene

func _ready() -> void:
	level_loaded.connect(_change_current_camera_exposure)
	Settings.connect("exposure_changed", _change_current_camera_exposure)
	load_scene(title_scene, true)

func launch_game() -> void:
	load_scene(hub_scene)

func _on_level_entered(level: PackedScene) -> void:
	load_scene(level)

func _on_level_reloaded() -> void:
	load_scene(current_packed_scene)

func _on_level_finished() -> void:
	load_scene(hub_scene)

func load_scene(scene: PackedScene, skip_transition: bool = false) -> void:
	if skip_transition == false:
		emit_signal("level_loading")
		await fade_player.animation_finished
	call_deferred("_load_scene_deffered", scene, skip_transition)

func _load_scene_deffered(scene: PackedScene, skip_transition: bool = false) -> void:
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
	if skip_transition == false:
		emit_signal("level_loaded")

func _change_current_camera_exposure():
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return

	if camera.attributes == null:
		var attributes = CameraAttributesPractical.new()
		camera.attributes = attributes

	camera.attributes.exposure_multiplier = Settings.get_setting("exposure")
