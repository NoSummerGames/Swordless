class_name DropdownButton
extends OptionButton

signal setting_changed

@export var setting_name: String
@export var data_name: String

func _ready() -> void:
	connect("item_selected", _on_setting_interacted)
	add_to_group("settings", true)

	var items_dict: Dictionary = Settings.get(data_name)
	for i: String in items_dict:
		var idx: int = items_dict[i]
		add_item(i.capitalize(), idx)

func _on_setting_interacted(index: int) -> void:
	setting_changed.emit(setting_name, index)
