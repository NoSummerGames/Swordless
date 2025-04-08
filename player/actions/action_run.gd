extends Action

func _execute(delta: float) -> void:
	if not player.is_on_floor():
		player.gravity += player.up_direction * player_stats.gravity * delta
	else:
		player.gravity = Vector3.ZERO
