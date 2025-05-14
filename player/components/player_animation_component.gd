extends AnimatedSprite3D

@export var commands_controller: CommandController

func _ready() -> void:
	commands_controller.command_entered.connect(_on_command_entered)
	commands_controller.command_exited.connect(_on_command_exited)
	animation_changed.connect(_on_animation_changed)


func _on_command_entered(command: Command) -> void:
	if command in commands_controller.active_commands:
		if play_animation("enter_animation"):
			await animation_finished

		play_animation("animation")

	else:
		if is_playing():
			await animation_finished
		play_animation(command.animation)

func _on_command_exited(command: Command) -> void:
		if sprite_frames.has_animation(command.exit_animation):
			play_animation(command.exit_animation)

func play_animation(property: String) -> bool:
	var desired_animation: String = commands_controller.get(property)

	if not property == null:
		if sprite_frames.has_animation(desired_animation):
			play(desired_animation)
			return true
		else:
			printerr(desired_animation + " animation couldn't be found.")
	else:
		printerr(property + " player property couldn't be found.")
	return false

func _on_animation_changed() -> void:
	print(animation)