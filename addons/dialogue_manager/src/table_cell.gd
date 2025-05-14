@tool
class_name TableCell
extends MarginContainer

signal cell_label_added

const CELL_LABEL: PackedScene = preload("res://addons/dialogue_manager/scenes/cell_label.tscn")

var child_dict: Dictionary[Character.Status, Array] = {}


@onready var new_dialogue: MenuButton = %NewDialogue
@onready var dialogue_container: VBoxContainer = %DialoguesContainer

@onready var popup: PopupMenu
@onready var items: Array[String]


func _ready() -> void:
	popup = new_dialogue.get_popup()
	items = _add_status_items()
	popup.id_pressed.connect(_on_item_selected)
	cell_label_added.connect(reorder_labels)

	for i in Character.Status.keys():
		child_dict[Character.Status[i]] = []

func _exit_tree() -> void:
	popup.clear()

func _add_status_items() -> Array[String]:
	var status_keys: Array = Character.Status.keys()
	var status_list: Array[String] = []
	for status_key in status_keys:
		var status: String = str(status_key).capitalize()
		popup.add_item(status)

		status_list.append(status)

	return status_list

func _on_item_selected(id: int) -> void:
	var status: String = items[id]
	var color: Color = ProjectSettings.get_setting("dialogue_manager/colors/" + status.to_snake_case())
	add_cell_label(color, id)


func add_cell_label(color: Color, id: int) -> void:
	var cell_label: CellLabel = CELL_LABEL.instantiate()

	var normal_stylebox: StyleBox = StyleBoxFlat.new()
	normal_stylebox.bg_color = color * Color(1,1,1,0.25)
	normal_stylebox.border_color = color * Color(1,1,1,0.5)
	normal_stylebox.set_border_width_all(2)
	cell_label.add_theme_stylebox_override("normal", normal_stylebox)

	var focus_stylebox: StyleBox = StyleBoxFlat.new()
	focus_stylebox.bg_color = color
	normal_stylebox.bg_color = color * Color(1,1,1,0.25)
	normal_stylebox.border_color = color * Color(1,1,1,0.5)
	normal_stylebox.set_border_width_all(2)
	cell_label.add_theme_stylebox_override("focus", focus_stylebox)

	cell_label.dialogue_state = id

	cell_label.selected.connect(_on_cell_label_selected)
	cell_label.deleted.connect(remove_cell_label)

	dialogue_container.add_child(cell_label)

	var array: Array = child_dict.get_or_add(id, [])
	array.append(cell_label)

	cell_label_added.emit()

	cell_label.grab_focus.call_deferred()

func remove_cell_label(cell_label: CellLabel) -> void:
	var array: Array = child_dict.get_or_add(cell_label.dialogue_state, [])
	array.erase(cell_label)
	cell_label.queue_free()


func reorder_labels() -> void:
	var index: int = 0
	for key: Character.Status in child_dict.size() - 1:
		for child: Node in child_dict[key]:
			dialogue_container.move_child(child, index)
			index += 1

func _on_cell_label_selected(cell_label: CellLabel) -> void:
	cell_label.grab_focus()
