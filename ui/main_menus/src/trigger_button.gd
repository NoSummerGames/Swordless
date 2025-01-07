class_name TriggerButton
extends Button

signal trigger_pressed
signal load_pressed

enum MenusTriggers {
	NONE = 0,
	PLAY = 1,
	QUIT = 2,
	RESTART = 3,
	EXIT = 4,
	RETURN = 5
}

@export var menu_to_load: MenuLoader.Menus
@export var trigger: MenusTriggers
@export var hovered: bool = false

func _ready() -> void:
	pressed.connect(_on_self_pressed)
	if hovered:
		call_deferred("grab_focus")


func _on_self_pressed() -> void:
	if trigger != MenusTriggers.NONE:
		trigger_pressed.emit(trigger)
	if menu_to_load != MenuLoader.Menus.NONE:
		load_pressed.emit(menu_to_load)
