class_name ActionDash
extends Action

var velocity_cached: Vector3
var dash: DashObject

func _enter() -> void:
	velocity_cached = player.velocity
	player.velocity_overridden = true

	dash = DashObject.new()
	dash.target = player
	set_dash_values()

	add_child(dash)

	var timer = Utilities.add_timer(true, player_stats.dash_duration)
	await timer.timeout
	if is_instance_valid(dash):
		dash.queue_free()
	player.velocity = velocity_cached
	player.velocity_overridden = false

	_exit()


func set_dash_values() -> void:
	dash.direction = -player.global_basis.z
	dash.strength = player_stats.dash_strength
	#var lateral_input: float = Input.get_action_strength("strafe_left") - Input.get_action_strength("strafe_right")
	#var forward_input: float = Input.get_action_strength("forward")
	#
	#if forward_input > player_stats.dash_sensitivity or player_stats.diagonal_strafe == true:
		#if abs(lateral_input) > player_stats.dash_sensitivity:
			#dash.direction = (-player.global_basis.z + player.global_basis.x * lateral_input).normalized()
			#if player_stats.diagonal_strafe == true:
				#dash.strength = player_stats.strafe_strength
			#else:
				#dash.strength = (player_stats.dash_strength + player_stats.strafe_strength) / 2
		#else :
			#dash.direction = -player.global_basis.z
			#dash.strength = player_stats.dash_strength
	#else:
		#if abs(lateral_input) > player_stats.dash_sensitivity:
			#dash.direction = player.global_basis.x * lateral_input
			#dash.strength = player_stats.strafe_strength
		#else :
			#dash.direction = -player.global_basis.z
			#dash.strength = player_stats.dash_strength
