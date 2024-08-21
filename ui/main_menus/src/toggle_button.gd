class_name ToggleButton
extends CheckButton

signal setting_changed

@export var setting_name: String

func _ready() -> void:
	connect("toggled", _on_setting_interacted)
	add_to_group("settings", true)

func _on_setting_interacted(value: Variant):
	emit_signal("setting_changed", setting_name, value)
