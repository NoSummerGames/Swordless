extends BaseJumpCommand

var wall_jump_timer: Timer

func _enter() -> void:
	# Reset gravity, especially for double jumping
	player.gravity = Vector3.ZERO
	timer =  Utilities.add_timer(true, player_stats.jump_time)
	timer.timeout.connect(fall_command.enter.bind(false))
	wall_jump_timer = Utilities.add_timer(true, player_stats.wall_jump_grace_time)


func _physics_process(delta: float) -> void:
	# Allow entering wall_jump command if conditions are met
	if wall_jump_timer and player.is_on_wall_only():
		var wall_jump: WallJumpCommand = %WallJump
		if wall_jump.check():
			wall_jump.enter()
			return

	if timer:
		if Input.is_action_just_released("jump") and timer.time_left >= player_stats.half_jump_timer:
			timer.start(player_stats.half_jump_timer)

		var strength: float = remap(timer.time_left, player_stats.jump_time, 0.0, START_SCALE, END_SCALE)
		player.command_velocity = player.up_direction * player_stats.jump_strength * strength
