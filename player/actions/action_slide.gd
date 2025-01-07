extends Action

var timer: Timer

@export var player_collision_shape: CollisionShape3D
@export var slide_shape: Shape3D
@export var default_shape: Shape3D
@export var player_mesh: MeshInstance3D
@export var slide_mesh: Mesh
@export var default_mesh: Mesh

func _enter() -> void:
	player_collision_shape.shape = slide_shape
	player_collision_shape.position = Vector3(0, 0.25, 0.1)
	player_mesh.mesh = slide_mesh
	player_mesh.position = Vector3(0, 0.25, 0)

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
	player_collision_shape.shape = default_shape
	player_collision_shape.position = Vector3(0, 0.8, 0.1)
	player_mesh.mesh = default_mesh
	player_mesh.position = Vector3(0, 0.8, 0)
	done = true
