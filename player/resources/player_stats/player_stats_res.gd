class_name PlayerStatsResource
extends CustomResource

var current_action: Action

@export_group("Velocity")
@export var speed: int = 30
@export var sprint_speed: int = 45
@export var lateral_factor: float = 0.6
@export var gravity: float = 35
@export var ground_acceleration: int = 15
@export var air_acceleration: int = 7
@export var coyote_time: float = 0.5

@export_group("Actions")
@export var jump_strength: int = 13
@export var dash_strength: int = 150
@export var strafe_strength: int = 60
@export var dash_duration: float = 0.1
@export var dash_sensitivity: float = 0.7
@export var dash_acceleration: float = 0.5
@export var wall_jump_strength: int = 18
@export var slide_duration: float = 0.6
@export var glide_strength: float = 3
@export var glide_acceleration: float = 0.5
@export var max_glide_duration: float = 0.7
@export var dive_strength: float = 20
@export var freeze_scale: float = 0.7

@export_group("Actions Misc")
@export var max_specials: int = 2
@export var input_buffer: int = 5
@export var priority_buffer: float = 0.2
@export var half_jump_buffer: float = 0.2
@export var half_jump_deceleration: float = 2
@export var floor_detection_margin: float = 0.5
@export var dash_deceleration: float = 2.0
@export_range(0.5, 1) var wall_jump_angle_range: float = 0.9
@export var diagonal_strafe: bool = true

@export_group("Path")
@export var interpolation_distance: float = 0.1
@export var path_stiffness: float = 4
@export var path_offset: int = 0

@export_group("Camera")
@export_exp_easing("positive_only") var camera_speed: float = 8.70
@export_exp_easing("positive_only") var freeze_camera_speed: float = 2.70
