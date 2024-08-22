extends ActionJump

func _enter() -> void:
	player.velocity.y = player.direction.y * player.speed + player_stats.double_jump_strength
	timer.wait_time = player_stats.half_jump_buffer
	timer.start()
