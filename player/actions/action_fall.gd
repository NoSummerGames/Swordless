class_name ActionFall
extends Action

func _check() -> bool:
	if current_action.input_required != Data.Actions.JUMP:
		return false
	return false if player.velocity.y > 0 else true

func _execute(delta: float) -> void:
	player.gravity += player.up_direction * player_stats.gravity * delta
