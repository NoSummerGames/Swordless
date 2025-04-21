extends Action

@onready var timer: Timer = Timer.new()

var start_scale: float = 1.0
var end_scale: float = 0.0


func _check() -> bool:
	var input_dir: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
	parameters.from = player.global_transform
	parameters.motion = -player.global_basis.x * input_dir
	var result : PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
	if PhysicsServer3D.body_test_motion(player.get_rid(), parameters, result) == true:
		var normal: Vector3 = result.get_collision_normal(0)
		if normal.dot(player.global_basis.x * input_dir) > 0.5:
			return true
	return false

func _ready() -> void:
	add_child(timer)
	timer.one_shot = true

func _enter() -> void:
	player.gravity = Vector3.ZERO
	custom_acceleration = player_stats.wall_jump_init_acceleration
	timer.wait_time = player_stats.wall_jump_time
	timer.start()

func _execute(delta: float) -> void:
	custom_acceleration = lerpf(custom_acceleration, player_stats.air_acceleration, \
	player_stats.wall_jump_deceleration * delta)

	if not timer.is_stopped():
		var strength: float = remap(timer.time_left, player_stats.wall_jump_time, 0.0, start_scale, end_scale)
		player.action_velocity = player.up_direction * player_stats.wall_jump_strength * strength
	else:
		_exit()
