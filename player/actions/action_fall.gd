extends Action

func _check() -> bool:
	if current_action.input_required != Data.Actions.JUMP:
		return false
	return false if player.velocity.y > 0 else true
