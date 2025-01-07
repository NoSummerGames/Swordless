class_name PlayerInputComponent
extends PlayerComponent

signal command_input(action: Data.Actions, param: Data.ActionParams)

var input_x: float = 0
var disabled: bool = false

func _physics_process(delta: float) -> void:
	if not disabled:
		_get_command_inputs()
		input_x = _get_lateral_input(delta)
		player.direction += input_x * player.transform.basis.x * player_stats.lateral_factor

func _get_lateral_input(delta: float) -> float:
	var input_right: float = Input.get_action_strength("right")
	var input_left: float = Input.get_action_strength("left")

	if player.is_on_wall():
		var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
		var motion_transform: Transform3D = player.global_transform
		parameters.from = motion_transform
		parameters.motion = player.global_basis.x * (input_right - input_left)
		var result : PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()

		if PhysicsServer3D.body_test_motion(player.get_rid(), parameters, result) == true:
			parameters.from = motion_transform
			parameters.motion = -player.global_basis.z
			var temp_result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
			if PhysicsServer3D.body_test_motion(player.get_rid(), parameters, temp_result) == true:
				var normal: Vector3 = result.get_collision_normal(0)
				# Lerp between left and right user action strengh
				var wall_normal: float = 0
				#var normal: Vector3 = player.get_wall_normal()
				var abs_normal: Vector3 = abs(normal)
				if abs_normal.dot(player.global_basis.x) > 0.5:
					wall_normal = normal.x

				input_right = input_right + sign(wall_normal) * input_right
				input_left = input_left - sign(wall_normal) * input_left


	var raw_input_x: float = input_right - input_left

	if player_stats.raw_lateral_input == true:
		return raw_input_x

	return lerp(input_x, raw_input_x, player.acceleration * delta)


func _get_command_inputs() -> void:
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
		command_input.emit(Data.Actions.FREEZE, 0)
