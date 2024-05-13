extends Action

var counter = 0
var can_exit = false

func _enter() -> void:
	can_exit = false
	has_slided = true
	player.scale.y = 0.3
	var timer = await Utilities.add_timer(true, player_stats.slide_duration)
	await timer.timeout
	can_exit = true
	player.scale.y = 1
	_exit()


func _execute(_delta: float):
	if can_exit == true:
		var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
		parameters.from = player.global_transform
		parameters.motion = Vector3(0, 1.1, 0)
		var result : PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
		PhysicsServer3D.body_test_motion(player.get_rid(), parameters, result)

		if result.get_collision_count() > 0:
			for i: int in result.get_collision_count():
				if result.get_collision_normal(i).dot(Vector3.DOWN) > 0:
					return
		player.scale.y = 1
		_exit()
