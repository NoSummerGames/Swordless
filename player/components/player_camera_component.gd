extends PlayerComponent

const max_fov: int = 179

@export var camera: Camera3D
@export var target: Marker3D

var death_fov: float = 125.0
var initial_transform: Transform3D
var initial_fov: float
var _dead: bool = false

func _ready() -> void:
	initial_transform = target.global_transform
	initial_fov = player_stats.camera_fov
	camera.fov = initial_fov
	# Camera doesn't inherit position from its parents
	camera.top_level = true

	player.died.connect(_on_player_dead)

func _physics_process(delta: float) -> void:
	target.position.y = player_stats.camera_height
	target.rotation.x = -player_stats.camera_pitch

	# Modulate camera fov based on velocity
	var target_fov: float = clamp(initial_fov + player.velocity.length() - player_stats.speed, initial_fov, max_fov)
	if not _dead:
		camera.fov = lerp(camera.fov, float(target_fov), player_stats.fov_reactivity * delta)
	else:
		camera.fov = lerp(camera.fov, death_fov, player_stats.fov_reactivity * delta)

	# Lock Z axis camera rotation
	target.global_rotation.z = 0

	# Lerp between camera position and camera_marker
	camera.global_transform = camera.global_transform.interpolate_with(target.global_transform, player_stats.camera_speed * delta)

func _on_player_dead() -> void:
	_dead = true
