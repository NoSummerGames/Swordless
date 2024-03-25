extends Action

func _execute(delta: float) -> void:
	match action_param:
		Data.ActionParams.START:
			player.velocity.z = lerp(player.velocity.z, player.velocity.z * player_stats.sprint_factor, player.acceleration * delta)
		Data.ActionParams.END:
			_exit()
