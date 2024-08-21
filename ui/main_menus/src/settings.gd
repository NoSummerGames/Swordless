extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_tree().get_nodes_in_group("settings"):
		child.connect("setting_changed", _on_setting_changed)

		if child is ToggleButton:
			child.button_pressed = Settings.get_setting(child.setting_name)
		if child is DropdownButton:
			child.selected = Settings.get_setting(child.setting_name)
		if child is SliderButton:
			child.value = Settings.get_setting(child.setting_name)


func _on_setting_changed(setting: String, value: Variant):
	Settings.change_setting(setting, value)
