extends Action

var timer: Timer

func _enter() -> void:
	timer = await Utilities.add_timer(true, player_stats.max_freeze_duration)
	await timer.timeout
	_exit()

func _execute(delta: float) -> void:
	var previous_velocity = player.velocity
	player.velocity = previous_velocity * player_stats.freeze_scale

	if action_param == Data.ActionParams.END:
		if is_instance_valid(timer):
			timer.queue_free()
		_exit()
