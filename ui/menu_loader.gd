class_name MenuLoader
extends CanvasLayer


static var current_menu: Control

enum Menus{
	NONE = 0,
	TITLE = 1,
	SETTINGS = 2,
	COMMANDS = 3,
	PAUSE = 4,
	VICTORY = 5,
	DEATH = 6
}

const MENUS_SCENES: Dictionary[Menus, PackedScene] = {
	Menus.NONE : null,
	Menus.TITLE : preload("res://ui/main_menus/title_menu.tscn"),
	Menus.SETTINGS : preload("res://ui/main_menus/settings_menu.tscn"),
	Menus.COMMANDS : preload("res://ui/main_menus/commands_menu.tscn"),
	Menus.PAUSE : preload("res://ui/main_menus/pause_menu.tscn"),
	Menus.VICTORY : null,
	Menus.DEATH : preload("res://ui/main_menus/death_menu.tscn")
}


func display_menu(menu_idx: Menus) -> void:
	if menu_idx == Menus.NONE:
		return

	var menu_scene: PackedScene = MENUS_SCENES[menu_idx]

	# Close current menu if any
	_close_menus()

	# Add "menu" as a child and set it to "current menu" as a reference
	if menu_scene != null:
		var instance: Control = menu_scene.instantiate()
		add_child(instance)
		current_menu = instance
		_connect_buttons()
	else:
		printerr("Menu {} not found".format([Menus.keys()[menu_idx]], "{}"))

func _connect_buttons() -> void:
	# Connect new menu buttons to _on_trigger_set virtual method
	for child: Control in Utilities.get_all_children(current_menu):
		if child is TriggerButton:
			var button: TriggerButton = child
			button.trigger_pressed.connect(_on_trigger_set)
			button.load_pressed.connect(_on_load_pressed)


func _close_menus() -> void:
	if is_instance_valid(current_menu):
		current_menu.queue_free()

func _on_level_loading() -> void:
	# TODO Prevent input handling when loading levels
	_close_menus()

func _on_level_loaded() -> void:
	# TODO Restore input handling when the level is loaded
	pass

func _on_trigger_set(_trigger: TriggerButton.MenusTriggers) -> void:
	pass

func _on_load_pressed(menu_to_load: Menus) -> void:
	display_menu(menu_to_load)
