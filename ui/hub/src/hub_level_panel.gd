class_name HubLevelPanel
extends MarginContainer

signal target_changed
signal closed

@export var name_label: Label
@export var description_label: Label
@export var baseline_label: Label
@export var variations: HFlowContainer

static var y_margin: float = 2
static var z_margin: float = 0
static var x_margin: float = 0.5

var target: HubObject:
	set(value):
		target = value
		position = _update_position(target)

var level: LevelResource:
	set(value):
		var last_value: LevelResource = level
		level = value
		if value != null and value != last_value:
			value.level_updated.connect(_update_level_informations.bind(value))
			_update_level_informations(value)

func _update_level_informations(_level: LevelResource) -> void:
	name_label.text = _level.name
	description_label.text = _level.description
	baseline_label.text = _level.baseline

	get_children().clear()
	for i: LevelVariationResource in _level.variations:
		var variant: VariantButton = VariantButton.new()
		variant.text = i.variation_name

		if (i as LevelVariationResource).discovered == false:
			variant.visible = false
		if (i as LevelVariationResource).finished == true:
			variant.theme_type_variation = "VariantButtonFinished"

		await get_tree().process_frame

		variant.pressed.connect(target.emit_signal.bind("passage_entered", i.variation_level))
		variant.pressed.connect(hide)

		variations.add_child(variant)


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
					emit_signal("closed")
