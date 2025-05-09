class_name AbstractCommand
extends PlayerComponent



static var current_command: Command

static var input_buffer: Array[Command.CommandInput]

static var lateral_input_buffer: Array[int]

static var priority_timer: Timer

static var specials_count: Array[Command] = []

static var command_controller: CommandController

static func _reset_specials_count() -> void:
	specials_count.clear()
