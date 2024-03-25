@tool
class_name Section
extends CustomResource

@export_range(50, 250) var length: int
@export var x_delta: float = 1
@export var y_delta: Vector2

@export var fixed: bool = false:
	set(value):
		fixed = value
		notify_property_list_changed()

@export var scale: float = 1
@export var parts_distance: Vector2i = Vector2i(2, 5)
@export var max_segments: int = 2
@export var fixed_scene: PackedScene

@export_dir var pool_dir : String

@export_flags(
	"Easy",
	"Medium",
	"Hard",
	"Air",
	"Hole",
	"Stairs"
	) var types: int


func _validate_property(property: Dictionary) -> void:
	if property.name in ["pool_dir", "types", "length"] and fixed == true:
		property.usage = PROPERTY_USAGE_READ_ONLY
	if property.name in ["fixed_scene"] and fixed == false:
		property.usage = PROPERTY_USAGE_READ_ONLY

