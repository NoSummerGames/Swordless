extends Node


func _unhandled_input(_event: InputEvent) -> void:
	if DebugUi.current_menu == null:
		if Input.is_action_just_pressed("select"):
			get_tree().paused = not get_tree().paused
