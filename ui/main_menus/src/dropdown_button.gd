class_name DropdownButton
extends OptionButton

signal setting_changed

@export var setting_name: String
@export var data_name: String

func _ready() -> void:
	connect("item_selected", _on_setting_interacted)
	add_to_group("settings", true)

	var items_dict = Settings.get(data_name)
	for i in items_dict:
		add_item(i.capitalize(), items_dict[i])



func _on_setting_interacted(index: int):
	emit_signal("setting_changed", setting_name, index)
