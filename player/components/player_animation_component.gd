extends AnimatedSprite3D

@export var commands_controller: CommandController


func _ready() -> void:
	commands_controller.command_entered.connect(_on_command_entered)
	commands_controller.command_exited.connect(_on_command_exited)
	animation_changed.connect(_on_animation_changed)


func _on_command_entered(command: Command) -> void:
	if command in commands_controller.active_commands:
		if try_playing(command.enter_animation):
			await animation_finished
			if animation != command.enter_animation:
				return

		try_playing(command.animation)

	else:
		if is_playing():
			await animation_finished
			try_playing(command.animation)

func _on_command_exited(command: Command) -> void:
		if sprite_frames.has_animation(command.exit_animation):
			play(command.exit_animation)

func try_playing(animation_name: String) -> bool:
	if sprite_frames.has_animation(animation_name):
		play(animation_name)
		return true
	else:
		return false

func _on_animation_changed() -> void:
	print(animation)
