class_name TutorialLevel
extends Node3D

signal level_exited

@onready var controls_ui: Control = %ControlsUI

func _ready() -> void:
	controls_ui.progress_bar_completed.connect(level_exited.emit)
