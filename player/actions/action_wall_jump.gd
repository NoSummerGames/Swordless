extends Action

func _check() -> bool:
	var input_dir: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
	parameters.from = player.global_transform
	parameters.motion = -player.global_basis.x * input_dir
	var result : PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
	if PhysicsServer3D.body_test_motion(player.get_rid(), parameters, result) == true:
		var normal: Vector3 = result.get_collision_normal(0)
		if normal.dot(player.global_basis.x * input_dir) > 0.5:
			return true
	return false

func _enter() -> void:
	player.velocity.y += player_stats.wall_jump_strength
	custom_acceleration = player_stats.wall_jump_init_acceleration

func _execute(delta: float) -> void:
	custom_acceleration = lerpf(custom_acceleration, player_stats.air_acceleration, \
	player_stats.wall_jump_deceleration * delta)
