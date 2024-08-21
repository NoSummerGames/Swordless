extends CanvasLayer

signal trigger_set

@export var menus: Dictionary
@export var world_loader : WorldLoader

var current_menu: Control:
	set(value):
		current_menu = value
		var children: Array = []
		Utilities.get_all_children(current_menu, children)
		for child in children:
			if child is TriggerButton:
				child.trigger_pressed.connect(_on_trigger_set)


func _ready() -> void:
	var title: PackedScene = menus["Title"]
	display_menu(title)

	world_loader.level_loading.connect(_on_level_loading)


func display_menu(menu_scene: PackedScene) -> void:
	# Close current menu if any
	close_menus()

	# Add "menu" as a child and set it to "current menu" as a reference
	if menu_scene != null:
		var instance: Control = menu_scene.instantiate()
		add_child(instance)
		current_menu = instance
	else:
		printerr("No menu found")

func close_menus() -> void:
	if is_instance_valid(current_menu):
		current_menu.queue_free()

func _on_level_loading() -> void:
	close_menus()

func _on_trigger_set(_trigger: String) -> void:
	match _trigger:
		"play":
			world_loader.launch_game()
		"settings":
			var settings: PackedScene = menus["Settings"]
			display_menu(settings)
		"main_back":
			var title: PackedScene = menus["Title"]
			display_menu(title)
		"settings_back":
			var settings: PackedScene = menus["Settings"]
			display_menu(settings)
		"commands":
			var commands: PackedScene = menus["Commands"]
			display_menu(commands)
		"quit":
			get_tree().quit()
