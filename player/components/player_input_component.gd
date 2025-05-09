class_name PlayerInputComponent
extends PlayerComponent

signal command_pressed(command: Command.CommandInput)

var input_x: float = 0
var disabled: bool = false

var actions_array: Array[StringName] = []


func _ready() -> void:
	_filter_actions()


func _physics_process(delta: float) -> void:
	if not disabled:
		input_x = _get_lateral_input(delta)
		player.direction += input_x * player.transform.basis.x * player_stats.lateral_factor


func _input(event):
	if not disabled:
		var action: StringName = ""

		for i in actions_array:
			if event.is_action_pressed(i):
				action = i
				break

		if not action.is_empty():
			if action in Command.command_dictionary.keys():
				command_pressed.emit(Command.command_dictionary[action])


func _get_lateral_input(delta: float) -> float:
	var input_right: float = Input.get_action_strength("right")
	var input_left: float = Input.get_action_strength("left")

	if player.is_on_wall():
		var motion_transform: Transform3D = player.global_transform
		var motion: Vector3 = player.global_basis.x * (input_right - input_left)
		var result : PhysicsTestMotionResult3D
		result = Utilities.test_collision(player.rid, motion_transform, motion)

		if result.get_collision_count() > 0:
			result = Utilities.test_collision(player.rid, motion_transform, -player.global_basis.z)
			if result.get_collision_count() > 0:
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


func _filter_actions():
	for action in InputMap.get_actions():
		if not action.begins_with("ui_"):
			actions_array.append(action)
