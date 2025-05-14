extends Camera3D

const max_fov: int = 125.0
const death_fov: float = 125.0

@export var player: Player
@export var target: Marker3D

var initial_transform: Transform3D
var initial_fov: float
var player_dead: bool = false

var player_stats: PlayerStatsResource:
	get:
		return player.player_stats

func _ready() -> void:
	initial_transform = target.global_transform
	initial_fov = player_stats.camera_fov
	fov = initial_fov
	# Camera doesn't inherit position from its parents
	top_level = true

	player.died.connect(_on_player_dead)

func _physics_process(delta: float) -> void:
	# HACK: Costy
	target.position.z = player_stats.camera_min_distance
	target.rotation.x = -player_stats.camera_pitch

	# Modulate camera fov based on velocity
	var target_fov: float = clamp(initial_fov + player.velocity.length() - player_stats.speed, initial_fov, max_fov)
	if not player_dead:
		fov = lerp(fov, float(target_fov), player_stats.fov_reactivity * delta)
	else:
		fov = lerp(fov, death_fov, player_stats.fov_reactivity * delta)

	# Lock Z axis camera rotation
	if player_stats.lock_camera_rotation:
		target.global_rotation.z = 0

	# Lerp between camera position and camera_marker
	global_transform = global_transform.interpolate_with(target.global_transform, player_stats.camera_speed * delta)

func _on_player_dead() -> void:
	player_dead = true
