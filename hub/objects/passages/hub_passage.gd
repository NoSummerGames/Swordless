class_name HubPassage
extends HubObject

@export var passage_resource: PassageResource

var panel: HubLevelPanel:
	set(value):
		if value != null and value != panel:
			panel = value
			panel.visibility_changed.connect(_on_panel_visibility_changed)
		elif value == null:
			busy = false

func _on_user_input(input: int) -> void:
	if input == Data.Inputs.PRESSED:
		fresh = false
		emit_signal("interacted", self)

func _on_panel_visibility_changed() -> void:
	if panel.visible:
		busy = true
	else:
		busy = false
