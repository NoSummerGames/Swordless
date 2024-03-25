extends Action

func _enter() -> void:
	has_slided = true
	player.scale.y = 0.3
	await Utilities.add_timer(true, player_stats.slide_duration)
	player.scale.y = 1
	_exit()


