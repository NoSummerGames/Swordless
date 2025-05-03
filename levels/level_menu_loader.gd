class_name LevelMenuLoader
extends MenuLoader

signal restart_pressed
signal exit_pressed

var level: Level

func _input(_event: InputEvent) -> void:
	if DebugUi._debug_menu == null and current_menu == null:
		if Input.is_action_just_pressed("start"):
			display_menu(Menus.PAUSE)
			get_tree().paused = true

	if Input.is_action_pressed("select"):
		get_tree().paused = not get_tree().paused

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
	_display_progress_bar()

func _on_player_reached_exit() -> void:
	display_menu(Menus.VICTORY)

func _display_progress_bar() -> void:
	var progress_bar: LevelProgressBar = LevelProgressBar.new(level)
	add_child(progress_bar)
