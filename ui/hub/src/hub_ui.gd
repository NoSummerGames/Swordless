class_name HubUI
extends Control

@export var panel: HubLevelPanel

func _on_passage_interacted(passage: HubPassage) -> void:
	if panel.target != passage:
		panel.emit_signal("target_changed")
		panel.target = passage
		panel.level = passage.level
		panel.target_changed.connect(passage.set.bind("panel", null))
	passage.panel = panel
	panel.visible = true
