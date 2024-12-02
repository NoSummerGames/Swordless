class_name PlayerInputComponent
extends PlayerComponent

signal command_input(action: Data.Actions, param: Data.ActionParams)

var input_x: float = 0

func _physics_process(delta: float) -> void:
	get_command_inputs()
	input_x = _get_lateral_input(delta)
	player.direction += input_x * player.transform.basis.x * player_stats.lateral_factor

func _get_lateral_input(delta: float) -> float:
	# Lerp between left and right user action strengh
	var wall_normal: float = 0
	if player.is_on_wall():
		var collision: KinematicCollision3D = player.get_last_slide_collision()
		for i: int in collision.get_collision_count():
			var normal: Vector3 = collision.get_normal(i)
			var abs_normal: Vector3 = abs(normal)
			if abs_normal.dot(player.global_basis.x) > 0.5:
				wall_normal = normal.x


	var input_right: float = Input.get_action_strength("right") + wall_normal * Input.get_action_strength("right")
	var input_left: float = Input.get_action_strength("left") - wall_normal * Input.get_action_strength("left")

	var raw_input_x: float = input_right - input_left
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
		command_input.emit(Data.Actions.FREEZE, 0)
