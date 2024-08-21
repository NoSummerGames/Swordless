class_name Player
extends CharacterBody3D

signal exited_path
signal restarted

## FIXME : added for testing purpose before having a proper "paths finding" script
@export var path: Path3D
@export var player_stats: PlayerStatsResource
@export var coyote_timer: Timer



var current_action: Action
var actions: Array[Action]

var velocity_overridden: bool = false
var direction: Vector3
var acceleration: float:
	get:
		if current_action.override_acceleration:
			return current_action.custom_acceleration
		elif is_almost_on_floor():
			return player_stats.ground_acceleration
		else:
			return player_stats.air_acceleration

var on_floor: bool = true

@onready var speed: float = player_stats.speed:
	get:
		if Input.is_action_pressed("sprint") and current_action.disable_sprint == false:
			return current_action.speed_factor * player_stats.sprint_speed
		else:
			return current_action.speed_factor * player_stats.speed

func _ready() -> void:
	## FIXME : added for testing purpose before having a proper "paths finding" script
	position = path.curve.get_point_position(1)

func _physics_process(delta: float) -> void:
	if not velocity_overridden:
		velocity.y += -player_stats.gravity * delta
		velocity.x = lerp(velocity.x, direction.normalized().x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.normalized().z * speed, acceleration * delta)

	move_and_slide()


func is_almost_on_floor() -> bool:
	var almost_on_floor: bool
	var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
	parameters.from = global_transform
	parameters.motion = Vector3(0, -player_stats.floor_detection_margin, 0)
	var result : PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
	PhysicsServer3D.body_test_motion(get_rid(), parameters, result)

	if result.get_collision_count() > 0:
		for i: int in result.get_collision_count():
			if result.get_collision_normal(i).y > 0.5:
				on_floor = true
				return true

	if on_floor == true:
		coyote_timer.start(player_stats.coyote_time)

	on_floor = false
	return false