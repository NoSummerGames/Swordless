extends Action


func _enter() -> void:
	player.velocity.y += player_stats.wall_jump_strength
	custom_acceleration = player_stats.wall_jump_init_acceleration
	wall_jumped_normal = player.get_last_slide_collision().get_normal().x

func _execute(delta: float) -> void:
	custom_acceleration = lerpf(custom_acceleration, player_stats.air_acceleration, \
	player_stats.wall_jump_deceleration * delta)
