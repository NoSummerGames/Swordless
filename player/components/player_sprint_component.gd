extends PlayerComponent

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("sprint") and player.current_action.disable_sprint == false:
		player.velocity -= player.global_transform.basis.z * player_stats.sprint_factor
