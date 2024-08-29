class_name PlayerInputComponent
extends PlayerComponent

signal command_input(action: Data.Actions, param: Data.ActionParams)

var input_x: float = 0
var input_y: float = 0

func _physics_process(delta: float) -> void:
	get_command_inputs()
	input_x = _get_lateral_input(delta)
	player.direction += input_x * player.transform.basis.x * player_stats.lateral_factor

func _get_lateral_input(delta: float) -> float:
	# Lerp between left and right user action strengh
	var raw_input_x: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	return lerp(input_x, raw_input_x, player.acceleration * delta)


func get_command_inputs() -> void:
	if Input.is_action_just_pressed("jump"):
		command_input.emit(Data.Actions.JUMP, 0)

	if Input.is_action_just_pressed("dash"):
		command_input.emit(Data.Actions.DASH, 0)

	if Input.is_action_just_pressed("strafe_left"):
		command_input.emit(Data.Actions.STRAFE, Data.ActionParams.LEFT)
	if Input.is_action_just_pressed("strafe_right"):
		command_input.emit(Data.Actions.STRAFE, Data.ActionParams.RIGHT)

	if Input.is_action_just_pressed("slide"):
		command_input.emit(Data.Actions.SLIDE, 0)

	if Input.is_action_pressed("glide"):
		command_input.emit(Data.Actions.GLIDE, Data.ActionParams.START)

	if Input.is_action_just_released("glide"):
		command_input.emit(Data.Actions.GLIDE, Data.ActionParams.END)

	if Input.is_action_pressed("freeze"):
		command_input.emit(Data.Actions.FREEZE)
