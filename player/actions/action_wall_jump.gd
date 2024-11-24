extends Action

func _check() -> bool:
	wall_jumped_normal = player.get_last_slide_collision().get_normal().x
	var input_dir: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	if sign(input_dir) == sign(wall_jumped_normal):
		if abs(input_dir) + player_stats.wall_jump_input_tolerance >= abs(wall_jumped_normal):
			return true
	return false


func _enter() -> void:
	player.velocity.y += player_stats.wall_jump_strength
	custom_acceleration = player_stats.wall_jump_init_acceleration

func _execute(delta: float) -> void:
	custom_acceleration = lerpf(custom_acceleration, player_stats.air_acceleration, \
	player_stats.wall_jump_deceleration * delta)
