extends PlayerComponent

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("dash"):
		var velocity = player.velocity.z
		player.velocity.z = lerpf(player.velocity.z, player.velocity.z -player_stats.sprint_addition, player_stats.sprint_acceleration * delta)
