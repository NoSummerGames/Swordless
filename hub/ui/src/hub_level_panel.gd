class_name HubLevelPanel
extends MarginContainer

signal passage_interacted
signal closed

@export var name_label: Label
@export var description_label: Label
@export var level_container: Control

static var y_margin: float = 2
static var z_margin: float = 0
static var x_margin: float = 0.5

var target: HubObject:
	set(value):
		target = value
		position = _update_position(target)

var level: PassageResource:
	set(value):
		if value != null and value != level:
			_update_level_informations(value)
			level = value


func _update_level_informations(_level: PassageResource) -> void:
	name_label.text = _level.name
	description_label.text = _level.description

	level_container.get_children().clear()

	var classic_button: LevelButton = LevelButton.new()
	classic_button.text = _level.classic_level
	classic_button.pressed.connect(passage_interacted.emit.bind(_level.classic_level_scene))
	classic_button.pressed.connect(hide)
	level_container.add_child(classic_button)
	if _level.classic_finished == true:
		classic_button.theme_type_variation = "LevelButtonFinished"

	if _level.blackened_unlocked == true:
		var blackened_button: LevelButton = LevelButton.new()
		blackened_button.text = _level.blackened_level
		blackened_button.pressed.connect(passage_interacted.emit.bind(_level.blackened_level_scene))
		blackened_button.pressed.connect(hide)
		level_container.add_child(blackened_button)
		if _level.blackened_finished == true:
			blackened_button.theme_type_variation = "LevelButtonFinished"


func _update_position(_target: HubObject) -> Vector2:
	var target_position: Vector3 = _target.global_position
	var target_aabb: AABB = (_target.visual_instance as VisualInstance3D).get_aabb()
	var top_point: Vector3 = target_position + Vector3(
		target_aabb.size.x / 2, target_aabb.size.y / 2, 0) + Vector3(
			x_margin, y_margin, z_margin
		)
	var unprojected_top_point: Vector2 = get_viewport().get_camera_3d().unproject_position(top_point)
	return unprojected_top_point


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton :
		if (event as InputEventMouseButton).pressed:
			if not get_global_rect().has_point(Vector2((event as InputEventMouseButton).global_position)):
				if self.visible:
					hide()
					closed.emit()
