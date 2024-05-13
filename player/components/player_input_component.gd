class_name PlayerInputComponent
extends PlayerComponent

signal command_input(action: Data.Actions, param: Data.ActionParams)

var input_x: float = 0
var input_y: float = 0

func _physics_process(delta: float) -> void:
	get_command_inputs()
	input_x = _get_lateral_input(delta)
	player.direction += input_x * player.transform.basis.x
	var raw_input_y: float = Input.get_action_strength("down")
	input_y = lerp(input_y, raw_input_y, player.acceleration * delta)
	player.direction -= input_y * player.transform.basis.y * 5

func _get_lateral_input(delta: float) -> float:
	# Lerp between left and right user action strengh
	var raw_input_x: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	return lerp(input_x, raw_input_x, player.acceleration * delta)


func get_command_inputs() -> void:
	if Input.is_action_just_pressed("jump"):
		emit_signal("command_input", Data.Actions.JUMP, 0)
	if Input.is_action_just_pressed("dash"):
		emit_signal("command_input", Data.Actions.DASH, 0)
	#if Input.is_action_just_pressed("strafe_left"):
		#emit_signal("command_input", Data.Actions.STRAFE, Data.ActionParams.LEFT)
	#if Input.is_action_just_pressed("strafe_right"):
		#emit_signal("command_input", Data.Actions.STRAFE, Data.ActionParams.RIGHT)
	#if Input.is_action_just_pressed("slide"):
		#emit_signal("command_input", Data.Actions.SLIDE, Data.ActionParams.START)
	if Input.is_action_just_released("slide"):
		emit_signal("command_input", Data.Actions.NONE, Data.ActionParams.END)
	if Input.is_action_pressed("slide"):
		emit_signal("command_input", Data.Actions.SLIDE, 0)
	if Input.is_action_pressed("freeze"):
		emit_signal("command_input", Data.Actions.FREEZE, Data.ActionParams.START)
	if Input.is_action_just_released("freeze"):
		emit_signal("command_input", Data.Actions.FREEZE, Data.ActionParams.END)
