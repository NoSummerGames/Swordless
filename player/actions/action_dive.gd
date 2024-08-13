extends Action


func _execute(delta: float) -> void:
	player.velocity = player.global_transform.basis.y * -player_stats.dive_strength

	if player.is_on_floor() == true:
		input.append(Data.Actions.SLIDE)
		_exit()
