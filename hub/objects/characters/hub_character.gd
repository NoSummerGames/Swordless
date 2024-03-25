class_name HubCharacter
extends HubObject


func _on_user_input(input: int) -> void:
	if input == Data.Inputs.PRESSED:
		emit_signal("interacted", self)

func _on_state_changed(_current: HubObjectState) -> void:
	pass
