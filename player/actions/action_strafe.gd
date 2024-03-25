extends ActionDash

func set_dash_values() -> void:
	if player_stats.diagonal_strafe == true:
		match action_param:
			Data.ActionParams.LEFT:
				dash.direction = (-player.transform.basis.x - player.transform.basis.z).normalized()
			Data.ActionParams.RIGHT:
				dash.direction = (player.transform.basis.x- player.transform.basis.z).normalized()
	else:
		match action_param:
			Data.ActionParams.LEFT:
				dash.direction = -player.transform.basis.x
			Data.ActionParams.RIGHT:
				dash.direction = player.transform.basis.x

	dash.strength = player_stats.strafe_strength
