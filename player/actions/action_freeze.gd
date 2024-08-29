extends Action

var timer: Timer

func _enter() -> void:
	timer = Utilities.add_timer(true, player_stats.freeze_duration)
	await timer.timeout
	_exit()

func _execute(_delta: float) -> void:
	var previous_velocity: Vector3 = player.velocity
	player.velocity = previous_velocity * player_stats.freeze_scale
