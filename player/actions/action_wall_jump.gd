extends Action


func _enter() -> void:
	player.velocity.y = 0
	var collision: Vector3 = player.get_last_slide_collision().get_normal()
	var direction: Vector3 = (Vector3.UP + collision).normalized()
	player.velocity = direction.normalized() * player_stats.wall_jump_strength


