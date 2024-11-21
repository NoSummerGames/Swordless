extends PlayerComponent

@export var camera: Camera3D
@export var camera_point: Marker3D

var initial_transform: Transform3D

func _ready() -> void:
	initial_transform = camera_point.global_transform

	# Camera doesn't inherit position from its parents
	camera.top_level = true

func _physics_process(delta: float) -> void:
	camera_point.position.y = player_stats.camera_height
	camera_point.rotation.x = -player_stats.camera_pitch
	camera_point.global_rotation.z = 0
	# Lerp between camera position and camera_marker
	if player.current_action.name == "Freeze":
		camera.global_transform = camera.global_transform.interpolate_with(camera_point.global_transform, player_stats.freeze_camera_speed * delta)
	else:
		camera.global_transform = camera.global_transform.interpolate_with(camera_point.global_transform, player_stats.camera_speed * delta)
