extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child: Control in get_tree().get_nodes_in_group("settings"):
		child.connect("setting_changed", _on_setting_changed)

		if child is ToggleButton:
			(child as ToggleButton).button_pressed = Settings.get_setting((child as ToggleButton).setting_name)
		if child is DropdownButton:
			(child as DropdownButton).selected = Settings.get_setting((child as DropdownButton).setting_name)
		if child is SliderButton:
			(child as SliderButton).value = Settings.get_setting((child as SliderButton).setting_name)

func _on_setting_changed(setting_name: String, setting_value: Variant) -> void:
	Settings.change_setting(setting_name, setting_value)
