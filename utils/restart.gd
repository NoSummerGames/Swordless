extends Node

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		get_tree().reload_current_scene()
		return
