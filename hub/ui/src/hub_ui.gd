class_name HubUi
extends Control

signal target_changed

@export var panel: HubLevelPanel

func _on_passage_interacted(passage: HubPassage) -> void:
	if panel.target != passage:
		target_changed.emit()
		panel.target = passage
		panel.level = passage.passage_resource
		target_changed.connect(passage.set.bind("panel", null))
	passage.panel = panel
	panel.visible = true
