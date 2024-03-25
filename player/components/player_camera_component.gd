extends PlayerComponent

@export var camera: Camera3D
@export var camera_point: Marker3D

var lerp_speed: float
var initial_transform: Transform3D

func _ready() -> void:
	initial_transform =camera_point.global_transform
	set_physics_process(false)
	# Camera doesn't inherit position from its parents
	player.restarted.connect(_on_player_restarted)
	camera.top_level = true

func _setup() ->void:
	lerp_speed = player_stats.camera_speed
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	# Lerp between camera position and camera_marker
	camera.global_transform = camera.global_transform.interpolate_with(camera_point.global_transform, lerp_speed * delta)

func _on_player_restarted():
	camera.global_transform = initial_transform
