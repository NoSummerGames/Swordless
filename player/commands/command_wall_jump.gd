class_name WallJumpCommand
extends BaseJumpCommand

func _check() -> bool:
	return true if is_player_opposing_a_wall() else false

func _enter() -> void:
	player.gravity = Vector3.ZERO
	custom_acceleration = player_stats.wall_jump_init_acceleration

	timer = Utilities.add_timer(true, player_stats.wall_jump_time)

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "custom_acceleration", player_stats.air_acceleration, player_stats.wall_jump_time)


func _physics_process(delta: float) -> void:
	if is_instance_valid(timer):
		var strength: float = remap(timer.time_left, player_stats.wall_jump_time, 0.0, START_SCALE, END_SCALE)
		player.command_velocity = player.up_direction * player_stats.wall_jump_strength * strength

func is_player_opposing_a_wall() -> bool:
	var wall_normal = player.get_wall_normal()
	return true if roundi(wall_normal.dot(player.global_basis.x)) in lateral_input_buffer else false
