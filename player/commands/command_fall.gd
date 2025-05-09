extends Command

func _check() -> bool:
	return true if player.velocity.y <= 0.0 else false

func _physics_process(delta: float) -> void:
	player.gravity += player.up_direction * player_stats.gravity * delta
