class_name WorldLoader # Use as a base class to load_scene()
extends AbstractWorldLoader

@export var title_scene: PackedScene
@export var hub_scene: PackedScene

func _ready() -> void:
	level_loaded.connect(_change_current_camera_exposure)
	Settings.connect("exposure_changed", _change_current_camera_exposure)
	load_scene(title_scene, true)

func launch_game() -> void:
	load_scene(hub_scene)


func _change_current_camera_exposure() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	if camera.attributes == null:
		var attributes: CameraAttributesPractical = CameraAttributesPractical.new()
		camera.attributes = attributes

	camera.attributes.exposure_multiplier = Settings.get_setting("exposure")

func _on_level_changed(level: Node3D) -> void:
		if level is Hub:
			(level as Hub).level_entered.connect(load_scene)
		if level is Level:
			(level as Level).level_exited.connect(load_scene.bind(hub_scene))
			(level as Level).level_restarted.connect(load_scene.bind(current_scene, true))
			(level as Level).standalone = false
