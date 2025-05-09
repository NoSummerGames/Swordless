class_name Command
extends AbstractCommand

enum CommandInput {NONE, JUMP, SPRINT, DASH, STRAFE_LEFT, STRAFE_RIGHT, SLIDE}
enum Space {GROUND, AIR}

@export var disabled: bool = false
@export var match_input: CommandInput = CommandInput.NONE
@export var repeatable: bool = false
@export var special: bool = false

@export_category("Movement")
@export var space: Space
@export var disable_sprint: bool = false
@export var speed_factor: float = 1.0
@export var override_acceleration: bool = false
@export var custom_acceleration: float = 0.0

@export_category("Conditions")
@export_flags(
	"on_ground",
	"in_air",
	"on_wall"
	) var conditions
@export var cooldown_time: float = 0.0

@export_category("Debug")
@export var debug_color: Color

var cooling_down: bool = false
var exclusive: bool = false

static var command_dictionary: Dictionary[StringName, CommandInput] = {
	"jump" : CommandInput.JUMP,
	"sprint" : CommandInput.SPRINT,
	"dash" : CommandInput.DASH,
	"strafe_left" : CommandInput.STRAFE_LEFT,
	"strafe_right" : CommandInput.STRAFE_RIGHT,
	"slide" : CommandInput.SLIDE
}


func check() -> bool:
	# Prevent entering the same command if it's not repeatable
	if not self.repeatable:
		if self == current_command:
			return false

	# Prevent entering if exceeding max specials or entering a second time
	# Else append to specials_count and return true
	if special:
		if self in specials_count or specials_count.size() > player_stats.max_specials:
			return false
		else:
			specials_count.append(self)

	return _check()


func enter(prioritary: bool = true) -> void:
	# Exit previous command and clear input buffer
	input_buffer.clear()
	current_command.exit()

	# Set the current command as self
	current_command = self
	command_controller.command_entered.emit(self)

	# If the command is prioritary (i.e. active) add a timer to prevent a passive command erasing it
	if prioritary:
		priority_timer = Utilities.add_timer(true, player_stats.priority_buffer)

	# If a cooldown_time is set, add a cooldown timer preventing command re-triggering
	if cooldown_time:
		_add_cooldown_timer(cooldown_time)

	# Enter the new command
	_enter()
	set_physics_process(true)


func exit() -> void:
	_exit()
	set_physics_process(false)


func _check() -> bool:
	return true


func _enter() -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _exit() -> void:
	pass

func _add_cooldown_timer(time: float) -> void:
	var timer: Timer = Utilities.add_timer(true, time)
	cooling_down = true
	timer.timeout.connect(func() -> void: cooling_down = false)
