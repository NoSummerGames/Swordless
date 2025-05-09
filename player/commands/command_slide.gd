class_name SlideCommand
extends Command

var timer: Timer

@export var player_collision_shape: CollisionShape3D
@export var slide_shape: Shape3D
@export var default_shape: Shape3D
@export var player_mesh: MeshInstance3D
@export var slide_mesh: Mesh
@export var default_mesh: Mesh


func _enter() -> void:
	exclusive = true
	_update_shape_and_mesh(slide_shape, slide_mesh)
	timer = Utilities.add_timer(true, player_stats.slide_duration)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(timer):
		if _test_height() == true:
			exclusive = false

	if not player.is_on_floor():
		player.gravity += player.up_direction * player_stats.gravity * delta
	else:
		player.gravity = Vector3.ZERO


func _test_height() -> bool:
	var result : PhysicsTestMotionResult3D = Utilities.test_collision(player.rid, player.global_transform, Vector3(0, 1.1, 0))
	if result.get_collision_count() > 0:
		return false
	else:
		return true


func _exit() -> void:
	_update_shape_and_mesh(default_shape, default_mesh)
	exclusive = false


func _update_shape_and_mesh(shape: Shape3D, mesh: Mesh) -> void:
	player_collision_shape.shape = shape
	player_collision_shape.position = Vector3(0, shape.get_debug_mesh().get_aabb().size.y / 2, 0.1)
	player_mesh.mesh = mesh
	player_mesh.position = Vector3(0, mesh.get_aabb().size.y / 2, 0)
