@tool
class_name EntryScene
extends Section


func _validate_property(property: Dictionary) -> void:
	var name: StringName = property.name
	if name == "fixed":
		self.set(name, true)
	if name in ["pool_dir", "types", "length"]:
		property.usage = PROPERTY_USAGE_READ_ONLY

