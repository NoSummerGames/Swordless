@tool
class_name Section
extends Resource

@export_range(50, 1000) var length: int = 250
@export var x_delta: float = 0.5
@export var hills_range: float = 0.25


@export var fixed: bool = false:
	set(value):
		fixed = value
		notify_property_list_changed()

@export var fixed_scene: PackedScene

@export_dir var pool_directory : String
@export_dir var junctions_directory : String
# HACK: a low junctions_length value can prevent loading any junction and cause errors
@export var junctions_length: int = 50
@export_range(0, 1) var smoothing_ratio: float = 0.5


func _validate_property(property: Dictionary) -> void:
	if property.name in [
		"pool_directory",
		"types",
		"length"
		] and fixed == true:
			property.usage = PROPERTY_USAGE_READ_ONLY

	if property.name in ["fixed_scene"] and fixed == false:
		property.usage = PROPERTY_USAGE_READ_ONLY
