class_name MainMenuLoader
extends MenuLoader

signal play_pressed


func _ready() -> void:
	display_menu(Menus.TITLE)

func _on_trigger_set(trigger: TriggerButton.MenusTriggers) -> void:
	match trigger:
		TriggerButton.MenusTriggers.PLAY:
			play_pressed.emit()
		TriggerButton.MenusTriggers.QUIT:
			get_tree().quit()
