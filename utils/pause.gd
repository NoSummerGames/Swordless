extends Node


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("select"):
		get_tree().paused = not get_tree().paused
