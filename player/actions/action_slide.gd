extends Action

var timer: Timer

func _enter() -> void:
	player.scale.y = 0.3
	timer = Utilities.add_timer(true, player_stats.slide_duration)

func _execute(_delta: float) -> void:
	if is_instance_valid(timer):
		await timer.timeout

	if _test_height() == false:
		return

	_exit()

func _test_height() -> bool:
	var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
	parameters.from = player.global_transform
	parameters.motion = Vector3(0, 1.1, 0)
	var result : PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
	PhysicsServer3D.body_test_motion(player.get_rid(), parameters, result)

	if result.get_collision_count() > 0:
		for i: int in result.get_collision_count():
			if result.get_collision_normal(i).dot(Vector3.DOWN) > 0.5:
				return false

	return true

func _exit() -> void:
	player.scale.y = 1
	done = true
