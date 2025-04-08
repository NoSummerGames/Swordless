extends Action

var timer: Timer

func _enter() -> void:
	timer = Utilities.add_timer(true, player_stats.max_glide_duration)
	await timer.timeout
	_exit()

func _execute(delta: float) -> void:
	player.gravity += player.up_direction * player_stats.glide_gravity * delta

	if player.is_almost_on_floor() == true:
		timer.queue_free()
		_exit()
