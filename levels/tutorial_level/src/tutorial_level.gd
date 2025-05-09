class_name TutorialLevel
extends Node3D

signal level_exited

var next_level: PackedScene:
	set(value):
		next_level = value
		if next_level:
			controls_ui.progress_bar_completed.connect(level_exited.emit.bind(next_level))
			controls_ui.is_ready = true


@onready var controls_ui: Control = %ControlsUI

func _ready() -> void:
	DebugUi.current_level = DebugUi.Levels.NONE
