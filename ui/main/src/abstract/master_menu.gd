class_name  MasterMenu
extends Control

signal trigger_set

@export var menus: Dictionary

var current_menu: Control

var trigger: String = "":
	set = _set_trigger

func _ready() -> void:
	pass


func display_menu(menu_scene: PackedScene) -> void:
	# Close current menu if any
	close_menus()
	# Add "menu" as a child and set it to "current menu" as a reference
	if menu_scene != null:
		var instance: GameMenu = menu_scene.instantiate()
		instance.master = self
		add_child(instance)
		current_menu = instance
	else:
		printerr("No menu found")

func close_menus() -> void:
	if current_menu != null:
		current_menu.queue_free()

func _set_trigger(new_trigger: String) -> void:
	# Called whenever "trigger" is set to a new value, most of the times by a slave node
	if new_trigger != "":
		trigger = new_trigger
		emit_signal("trigger_set", trigger)
		trigger = ""








