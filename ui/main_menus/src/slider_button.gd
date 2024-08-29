class_name SliderButton
extends HSlider

signal setting_changed

@export var setting_name: String

func _ready() -> void:
	connect("value_changed", _on_setting_interacted)
	add_to_group("settings", true)

func _on_setting_interacted(setting_value: Variant) -> void:
	setting_changed.emit(setting_name, setting_value)
