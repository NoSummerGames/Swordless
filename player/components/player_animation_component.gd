extends AnimatedSprite3D

@export var commands_controller: CommandController

func _ready() -> void:
	commands_controller.command_entered.connect(_on_command_entered)
	animation_changed.connect(_on_animation_changed)


func _on_command_entered(from: Command, to: Command) -> void:
	if to not in commands_controller.active_commands:
		if play_animation(from, "exit_animation"):
			await animation_finished

	if play_animation(to, "enter_animation"):
		await animation_finished

	play_animation(to, "animation")


func play_animation(command: Command, property: String) -> bool:
	var get_property: Variant = command.get(property)

	var get_anim: Callable = func() -> String: return "" if get_property == null else get_property
	var desired_animation: String = get_anim.call()

	if not desired_animation == "":
		if sprite_frames.has_animation(desired_animation):
			# Mirror animation
			if command.mirror_animation: flip_h = true
			else: flip_h = false

			# If the animation is the same set its progress to zero
			if desired_animation == animation:
				frame = 0

			play(desired_animation)
			return true
		else:
			printerr(desired_animation + " animation couldn't be found.")

	return false

func _on_animation_changed() -> void:
	print(animation)
