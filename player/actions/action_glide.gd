extends Action

func _enter() -> void:
	await Utilities.add_timer(true, player_stats.max_glide_duration)
	_exit()

func _execute(delta: float) -> void:
	match action_param:
		Data.ActionParams.START:
			player.velocity.y = lerpf(player.velocity.y, player_stats.glide_strength, player_stats.glide_acceleration * delta)
		Data.ActionParams.END:
			_exit()

	if player.is_almost_on_floor() == true:
		_exit()
