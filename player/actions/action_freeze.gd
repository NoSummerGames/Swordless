extends Action

var timer: Timer
var previous_velocity

func _enter() -> void:
	timer = await Utilities.add_timer(true, player_stats.max_glide_duration)
	await timer.timeout
	previous_velocity = player.velocity
	_exit()

func _execute(delta: float) -> void:
	#player.direction += -player.transform.basis.y
	var previous_velocity = player.velocity
	player.velocity = previous_velocity * player_stats.freeze_scale
	#lerpf(player.velocity.y, player_stats.glide_strength, player_stats.glide_acceleration * delta)
	if action_param == Data.ActionParams.END:
		if is_instance_valid(timer):
			timer.queue_free()
		_exit()

#func _execute(delta: float) -> void:
	#player.velocity.y = lerpf(player.velocity.y, player_stats.glide_strength, player_stats.glide_acceleration * delta)
	#if action_param == Data.ActionParams.END:
		#if is_instance_valid(timer):
			#timer.queue_free()
		#_exit()
#
	#if player.is_almost_on_floor() == true:
		#if is_instance_valid(timer):
			#timer.queue_free()
		#_exit()
