extends Command


func _physics_process(_delta: float) -> void:
	player.command_velocity = player.global_transform.basis.y * -player_stats.dive_strength
	input_buffer.append(CommandInput.SLIDE)
	if player.on_floor == true:
		var slide_command: SlideCommand = %Slide
		slide_command.enter()
