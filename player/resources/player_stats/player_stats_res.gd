class_name PlayerStatsResource
extends Resource

var current_action: Action

@export_group("Velocity")
@export var speed: int = 25
@export var sprint_speed: int = 40
@export var lateral_factor: float = 0.6
@export var gravity: float = 60
@export var ground_acceleration: float = 19
@export var air_acceleration: float = 9
@export_range(0.0, 1.0) var min_slope_speed: float = 0.8

@export_group("Misc")
@export var max_specials: int = 2
@export var coyote_time: float = 0.2
@export var max_step_height: float = 0.5
@export var stairs_speed: float = 0.5
@export var input_buffer: int = 5
@export var floor_detection_margin: float = 0.5
@export var freeze_scale: float = 0.2
@export var freeze_duration: float = 0.7
@export var raw_lateral_input: bool = true
@export_range(0.0, 1.0, 0.1) var death_accuracy: float = 0.8

@export_group("Actions")
@export var jump_strength: int = 15
@export var jump_time: float = 0.4
@export_range(100, 600) var dash_strength: int = 150
@export var strafe_strength: int = 40
@export var dash_duration: float = 0.1
@export var dash_sensitivity: float = 0.7
@export var dash_acceleration: float = 0.5
@export var wall_jump_strength: int = 13
@export var wall_jump_time: float = 0.5
@export var wall_jump_init_acceleration: float = 80
@export var wall_jump_deceleration: float = 0.8
@export var slide_duration: float = 0.5
@export var glide_strength: float = 4.0
@export var glide_gravity: float = 25
@export var glide_acceleration: float = 0.5
@export var max_glide_duration: float = 0.7
@export var dive_strength: float = 40

@export_group("Actions Misc")
@export var priority_buffer: float = 0.2
@export var half_jump_timer: float = 0.2
@export var dash_deceleration: float = 2.0
@export_range(0.5, 1) var wall_jump_angle_range: float = 0.5
@export_range(0,1) var wall_jump_input_tolerance: float = 0.5
@export var diagonal_strafe: bool = true
@export var local_gravity: bool = false


@export_group("Path")
@export var interpolation_distance: float = 5.0
@export var path_stiffness: float = 2.0
@export var path_offset: int = 5

@export_group("Camera")
@export var camera_speed: float = 5.0
@export var camera_min_distance: float = 0.5
@export var camera_height: float = 2.5
@export_range(-0.5, 0.5) var camera_pitch: float = 0.1
@export_range(50, 170, 5) var camera_fov: int = 85
@export var fov_reactivity: int = 4
@export var lock_camera_rotation: bool = false
