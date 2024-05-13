@tool
class_name ToolboxCreateButton
extends Button

@export var type: StringName

func _enter_tree() -> void:
	if not pressed.is_connected(Callable(owner, "_on_create_button_pressed")):
		connect("pressed", Callable(owner, "_on_create_button_pressed").bind(type))
