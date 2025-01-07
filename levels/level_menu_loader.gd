class_name LevelMenuLoader
extends MenuLoader


signal restart_pressed
signal exit_pressed


func _input(_event: InputEvent) -> void:
	if DebugUi._debug_menu == null and current_menu == null:
		if Input.is_action_just_pressed("start"):
			display_menu(Menus.PAUSE)
			get_tree().paused = true

func _ready() -> void:
	DebugUi.debug_menu_opened.connect(_close_menus)

func _on_trigger_set(trigger: TriggerButton.MenusTriggers) -> void:
	get_tree().paused = false
	_close_menus()
	match trigger:
		TriggerButton.MenusTriggers.RESTART:
			restart_pressed.emit()
		TriggerButton.MenusTriggers.EXIT:
			exit_pressed.emit()
		TriggerButton.MenusTriggers.RETURN:
			pass

func _on_player_died() -> void:
	display_menu(Menus.DEATH)

func _on_player_reached_exit() -> void:
	display_menu(Menus.VICTORY)
