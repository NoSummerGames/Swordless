class_name BaseJumpCommand
extends Command

const START_SCALE: float = 1.0
const END_SCALE: float = 0.0

var timer: Timer


@onready var fall_command: Command = %Fall

func _exit() -> void:
	if is_instance_valid(timer):
		timer.queue_free()
