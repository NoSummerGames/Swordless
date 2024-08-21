extends CanvasLayer

@export var stat_menu: PackedScene

var categories: Dictionary = {}
var stats: Dictionary
@onready var option_menu: PopupMenu = %MenuButton.get_popup()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_tree().get_nodes_in_group("settings"):
		child.connect("setting_changed", _on_setting_changed)

		if child is ToggleButton:
			child.button_pressed = DebugUi.get_setting(child.setting_name)
		if child is DropdownButton:
			child.selected = DebugUi.get_setting(child.setting_name)
		if child is SliderButton:
			child.value = DebugUi.get_setting(child.setting_name)

	var id: int = 1
	var category: String = ""
	var cat_label: Label
	var cat_id = 0
	var submenu: PopupMenu
	for property in DebugUi.player_stats.get_property_list():
		if property.usage == 64 and property.name != "Resource":
			cat_id = 0
			category = property.name.capitalize()

			categories[category] = 0

			cat_label = Label.new()
			cat_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cat_label.theme = ThemeDB.get_project_theme()
			cat_label.text = category
			cat_label.visible = false
			%StatsContainer.add_child(cat_label)

			submenu = PopupMenu.new()
			option_menu.add_child(submenu)
			option_menu.add_submenu_node_item(category, submenu)
			submenu.id_pressed.connect(_on_stat_pressed)

			id += 1

		if property.usage == 4102 and property.name not in DebugUi.excluded_stats:
			submenu.add_item(property.name.to_pascal_case(), id)
			stats[id] = {}
			stats[id]["name"] = property.name
			stats[id]["type"] = property.type
			stats[id]["range"] = property.hint_string
			stats[id]["category"] = category
			stats[id]["id"] = id
			stats[id]["label"] = cat_label
			stats[id]["cat_id"] = cat_id
			cat_id += 1
			id += 1


	for saved_stat in DebugUi.stats.keys():
		for n in stats:
			if stats[n]["name"] == saved_stat:
				_add_stat_line(stats[n])

func _add_stat_line(setting):
	if categories[setting["category"]] == 0:
		setting["label"].show()

	categories[setting["category"]] += 1

	var stat_line: HBoxContainer = HBoxContainer.new()
	stat_line.set_anchors_preset(Control.PRESET_TOP_WIDE)

	%StatsContainer.add_child(stat_line)
	%StatsContainer.move_child(stat_line, setting["label"].get_index() + 1)

	var close_button: Button = Button.new()
	close_button.text = "X"
	stat_line.add_child(close_button)
	close_button.button_up.connect(_on_stat_line_erased.bind(stat_line, setting))

	var stat_label: Label = Label.new()
	stat_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_label.theme = ThemeDB.get_project_theme()
	var text: String = setting["name"]
	stat_label.text = text.capitalize()
	stat_line.add_child(stat_label)

	var property_value = DebugUi.player_stats.get(setting["name"])

	match setting["type"]:
		0: return
		1:
			var check_box: CheckBox = CheckBox.new()
			stat_line.add_child(check_box)
			check_box.button_pressed = property_value
			check_box.toggled.connect(_on_stat_changed.bind(setting["name"]))
		2:
			var spin_box: SpinBox = SpinBox.new()
			stat_line.add_child(spin_box)
			spin_box.step = 1
			spin_box.alignment = HORIZONTAL_ALIGNMENT_CENTER
			var hint: String = setting["range"]
			if hint != "":
				var range: PackedFloat64Array = hint.split_floats(",", false)
				spin_box.min_value = range[0]
				spin_box.max_value = range[1]
			spin_box.connect("value_changed", _on_stat_changed.bind(setting["name"]))
			spin_box.value = property_value
		3:
			var spin_box: SpinBox = SpinBox.new()
			stat_line.add_child(spin_box)
			spin_box.step = 0.1
			spin_box.alignment = HORIZONTAL_ALIGNMENT_CENTER
			var hint: String = setting["range"]
			if hint != "":
				var range: PackedFloat64Array = hint.split_floats(",", false)
				spin_box.min_value = range[0]
				spin_box.max_value = range[1]
			spin_box.connect("value_changed", _on_stat_changed.bind(setting["name"]))
			spin_box.value = property_value

	DebugUi.change_stat(setting["name"], property_value)



	var category_index: int
	var submenu: PopupMenu
	for i in option_menu.item_count:
		if option_menu.get_item_text(i) == setting["category"]:
			submenu = option_menu.get_item_submenu_node(i)

	if submenu != null:
		var index = submenu.get_item_index(setting["id"])
		submenu.set_item_disabled(index, true)
		stat_line.tree_exited.connect(Callable(submenu, "set_item_disabled").bind(index, false))

func _on_stat_line_erased(stat_line: HBoxContainer, stat: Dictionary):
	DebugUi.clear_stat(stat["name"])
	categories[stat["category"]] -= 1
	stat_line.queue_free()
	if categories[stat["category"]] == 0:
		stat["label"].hide()

func _on_stat_pressed(id: int):
	_add_stat_line(stats[id])

func _on_setting_changed(setting: String, value: Variant):
	DebugUi.change_setting(setting, value)

func _on_stat_changed(value: Variant, stat: String):
	DebugUi.change_stat(stat, value)
