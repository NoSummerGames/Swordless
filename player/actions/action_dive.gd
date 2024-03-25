extends Action


func _execute(delta: float) -> void:
	player.velocity.y = lerpf(player.velocity.y, -player_stats.dive_strength, player.acceleration * delta)


	if player.is_on_floor() == true:
		_exit()
