@tool
class_name Section
extends BaseSection

@export_range(50, 1000) var length: int = 250
@export var x_delta: float = 0.5
@export_range(-2, 2) var low_delta: float = -0.5
@export_range(-2, 2) var high_delta: float = 0.25

@export var fixed: bool = false:
	set(value):
		fixed = value
		notify_property_list_changed()



@export var max_segments: int = 2
@export var fixed_scene: PackedScene

@export_dir var pool_dir : String


func _validate_property(property: Dictionary) -> void:
	if property.name in ["pool_dir", "types", "length"] and fixed == true:
		property.usage = PROPERTY_USAGE_READ_ONLY
	if property.name in ["fixed_scene"] and fixed == false:
		property.usage = PROPERTY_USAGE_READ_ONLY
