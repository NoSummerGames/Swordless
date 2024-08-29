class_name ToggleButton
extends CheckButton

signal setting_changed

@export var setting_name: String

func _ready() -> void:
	connect("toggled", _on_setting_interacted)
	add_to_group("settings", true)

func _on_setting_interacted(value: Variant) -> void:
	setting_changed.emit(setting_name, value)
