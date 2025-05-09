class_name CommandController
extends AbstractCommand

signal command_entered(command: Command)

@export var input_controller: PlayerInputComponent
@export var default_command: Command

static var passive_commands: Array[Command] = []
static var active_commands: Array[Command] = []

static var inputs_counter: Array[int] = [0]

var wall_timer: Timer

var conditions : Array[Callable] = [
	# on_ground
	func() -> bool: return player.on_floor,
	# in_air
	func() -> bool: return not player.on_floor,
	# on_wall
	func() -> bool:
	var on_wall: bool = player.is_on_wall_only()
	if on_wall :
		wall_timer = Utilities.add_timer(true, player.player_stats.wall_jump_grace_time)
		return true
	elif is_instance_valid(wall_timer):
		return true
	else:
		return false
	]

var conditions_bitflag: int


func _ready() -> void:
	player.command_controller = self
	command_controller = self
	current_command = default_command
	input_controller.command_pressed.connect(_store_command_in_input_buffer)
	_setup_commands()


func _physics_process(delta: float) -> void:
	if player.on_floor:
		_reset_specials_count()

	_update_input_buffer(player.player_stats.input_buffer_frames)
	_update_lateral_input_buffer(roundi(player_stats.wall_jump_grace_time / delta))
	_update_conditions()

	# Update the current_command only if it's not in exclusive state
	if not current_command.exclusive:
		_update_commands()


## Set the condition_bitflag by checking each condition
func _update_conditions() -> void:
	conditions_bitflag = 0
	for i in conditions.size():
		if conditions[i].call() == true:
			conditions_bitflag += 1 << i


## Iterate over each Command child to check if they can be entered
func _update_commands() -> void:
	# Compare active commands first
	# If no input is stored only passive commands are compared
	if not input_buffer.is_empty():
		for command in active_commands:
			# Only compare commands whose matching inputs are in the input buffer and that are not cooling down
			if command.match_input in input_buffer and not command.cooling_down and not command.disabled:
				if command.conditions == null:
					if command.check() == true:
						command.enter()
						return
				if match_flags(command, conditions_bitflag) == true:
					command.enter()
					return

	#INFO : the two lines below extracted from legacy _action, not sure reason behind them
	if current_command is SlideCommand and current_command.exclusive == true:
		return

	# Then compare passive commands if no active one returned
	if not priority_timer:
		for command: Command in passive_commands:
			if match_flags(command, conditions_bitflag) == true:
				command.enter(false)
				return

## Check if two condition bitflags match
static func match_flags(command: Command, conditions: int) -> bool:
	# Compare only the matching conditions
	var compared_conditions: int = command.conditions & conditions
	if command.conditions == compared_conditions:
		if command.check() == true:
			return true

	return false


## Append command inputs to the input buffer and store input count for that frame in an array
static func _store_command_in_input_buffer(command: Command.CommandInput):
	input_buffer.append(command)
	inputs_counter[inputs_counter.size() -1] += 1


## Set this frame inputs_counter to zero and remove according to the oldest input count
static func _update_input_buffer(size: int) -> void:
	inputs_counter.append(0)

	var count: int = inputs_counter.front()

	for i in count:
		input_buffer.pop_front()

	while inputs_counter.size() - 1 > size:
		inputs_counter.pop_front()

static func _update_lateral_input_buffer(size: int) -> void:
	var input_dir: int = roundi(Input.get_action_strength("right") - Input.get_action_strength("left"))
	if input_dir != 0:
		lateral_input_buffer.append(input_dir)
	else:
		lateral_input_buffer.append(0)

	while lateral_input_buffer.size() - 1 > size:
		lateral_input_buffer.pop_front()

## Store commands in two separate array to fasten further iteration
func _setup_commands() -> void:
	passive_commands.clear()
	active_commands.clear()

	for child: Command in get_children():
		if not child == default_command:
			child.set_physics_process(false)

		if child.match_input == Command.CommandInput.NONE:
			# If a command doesn't need any input to be triggered it's passive
			passive_commands.append(child)
		else:
			# Else it's an active one
			active_commands.append(child)
