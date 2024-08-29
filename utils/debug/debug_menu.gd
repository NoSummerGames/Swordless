extends CanvasLayer

@export var stat_menu: PackedScene

var categories: Dictionary = {}
var stats: Dictionary

@onready var debug: Debug = DebugUi
@onready var menu_button: MenuButton = %MenuButton
@onready var option_menu: PopupMenu = menu_button.get_popup()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child: Control in get_tree().get_nodes_in_group("settings"):
		child.connect("setting_changed", _on_setting_changed)

		if child is ToggleButton:
			var button: ToggleButton = child
			button.button_pressed = debug.get_setting(button.setting_name)
		if child is DropdownButton:
			var button: DropdownButton = child
			button.selected = debug.get_setting(button.setting_name)
		if child is SliderButton:
			var button: SliderButton = child
			button.value = debug.get_setting(button.setting_name)

	var id: int = 1
	var category: String = ""
	var cat_label: Label
	var cat_id: int = 0
	var submenu: PopupMenu

	for property: Dictionary in  debug.player_stats.get_property_list():
		if property.usage == 64 and property.name != "Resource":
			var stat_name: String = property.name
			cat_id = 0
			category = stat_name.capitalize()

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

		if property.usage == 4102 and property.name not in debug.excluded_stats:
			var property_name: String = property.name
			submenu.add_item(property_name.capitalize(), id)
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


	for saved_stat: String in debug.stats.keys():
		for n: int in stats:
			if stats[n]["name"] == saved_stat:
				var stat: Dictionary = stats[n]
				_add_stat_line(stat)

func _add_stat_line(stat: Dictionary) -> void:
	var stat_name: String = stat["name"]
	var stat_label: Label = stat["label"]

	if categories[stat["category"]] == 0:
		stat_label.show()

	categories[stat["category"]] += 1

	var stat_line: HBoxContainer = HBoxContainer.new()
	stat_line.set_anchors_preset(Control.PRESET_TOP_WIDE)

	%StatsContainer.add_child(stat_line)
	%StatsContainer.move_child(stat_line, stat_label.get_index() + 1)

	var close_button: Button = Button.new()
	close_button.text = "X"
	stat_line.add_child(close_button)
	close_button.button_up.connect(_on_stat_line_erased.bind(stat_line, stat))

	var label: Label = Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.theme = ThemeDB.get_project_theme()
	label.text = stat_name.capitalize()
	stat_line.add_child(label)

	var property_value: Variant = debug.player_stats.get(stat_name)

	match stat["type"]:
		0: return
		1:
			var check_box: CheckBox = CheckBox.new()
			stat_line.add_child(check_box)
			check_box.button_pressed = property_value
			check_box.toggled.connect(_on_stat_changed.bind(stat_name))
		2:
			var spin_box: SpinBox = SpinBox.new()
			stat_line.add_child(spin_box)
			spin_box.step = 1
			spin_box.alignment = HORIZONTAL_ALIGNMENT_CENTER
			var hint: String = stat["range"]
			if hint != "":
				var stat_range: PackedFloat64Array = hint.split_floats(",", false)
				spin_box.min_value = stat_range[0]
				spin_box.max_value = stat_range[1]
			spin_box.connect("value_changed", _on_stat_changed.bind(stat_name))
			spin_box.value = property_value
		3:
			var spin_box: SpinBox = SpinBox.new()
			stat_line.add_child(spin_box)
			spin_box.step = 0.1
			spin_box.alignment = HORIZONTAL_ALIGNMENT_CENTER
			var hint: String = stat["range"]
			if hint != "":
				var stat_range: PackedFloat64Array = hint.split_floats(",", false)
				spin_box.min_value = stat_range[0]
				spin_box.max_value = stat_range[1]
			spin_box.connect("value_changed", _on_stat_changed.bind(stat_name))
			spin_box.value = property_value

	debug.change_stat(stat_name, property_value)


	var submenu: PopupMenu
	for i: int in option_menu.item_count:
		if option_menu.get_item_text(i) == stat["category"]:
			submenu = option_menu.get_item_submenu_node(i)

	if submenu != null:
		var id: int = stat["id"]
		var index: int = submenu.get_item_index(id)
		submenu.set_item_disabled(index, true)
		stat_line.tree_exited.connect(Callable(submenu, "set_item_disabled").bind(index, false))

func _on_stat_line_erased(stat_line: HBoxContainer, stat: Dictionary) -> void:
	var stat_name: String = stat["name"]
	debug.clear_stat(stat_name)
	categories[stat["category"]] -= 1
	stat_line.queue_free()
	if categories[stat["category"]] == 0:
		var label: Label = stat["label"]
		label.hide()

func _on_stat_pressed(id: int) -> void:
	var stat: Dictionary = stats[id]
	_add_stat_line(stat)

func _on_setting_changed(setting: String, setting_value: Variant) -> void:
	debug.change_setting(setting, setting_value)

func _on_stat_changed(stat_value: Variant, stat: String) -> void:
	debug.change_stat(stat, stat_value)
