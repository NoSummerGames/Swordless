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

@onready var collider_margin: float = %PlayerCollision.shape.margin
@onready var speed: float = player_stats.speed:
	get:
		if Input.is_action_pressed("sprint") and current_action.disable_sprint == false:
			return current_action.speed_factor * player_stats.sprint_speed
		else:
			return current_action.speed_factor * player_stats.speed

#func _ready() -> void:
	### FIXME : added for testing purpose before having a proper "paths finding" script
	#position = path.curve.get_point_position(1)

func _physics_process(delta: float) -> void:
	if not velocity_overridden:
		var floor_angle = 1.0

		if floor_constant_speed == false:
			floor_angle -= get_floor_angle(up_direction) * signf(get_floor_normal().z)

		up_direction = global_basis.y

		if not is_on_floor():
			velocity.y -= player_stats.gravity * delta

		velocity.z = lerp(velocity.z, direction.normalized().z * speed * floor_angle, acceleration * delta)
		velocity.x = lerp(velocity.x, direction.normalized().x * speed, acceleration * delta)

	move_and_slide()
	test_stairs_up(delta)



func is_almost_on_floor() -> bool:
	var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
	parameters.from = global_transform
	parameters.motion = Vector3(0, -player_stats.floor_detection_margin, 0)
	var result : PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
	PhysicsServer3D.body_test_motion(get_rid(), parameters, result)

	if result.get_collision_count() > 0:
		for i: int in result.get_collision_count():
			var normal: Vector3 = result.get_collision_normal(i)
			if normal.y > 0.5:
				on_floor = true
				return true

	if on_floor == true:
		coyote_timer.start(player_stats.coyote_time)

	on_floor = false
	return false

func test_stairs_up(delta: float):
	# Minor rework of "Stairs Character" script by Andicraft
	const HORIZONTAL = Vector3(1, 0, 1)
	var motion_velocity = velocity * HORIZONTAL * delta

	# Test collision
	var motion_transform = global_transform
	var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
	parameters.from = motion_transform
	parameters.motion = motion_velocity
	var result : PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
	if PhysicsServer3D.body_test_motion(get_rid(), parameters, result) == false:
		# No wall was hit
		return

	if result.get_collision_normal(0).angle_to(Vector3.UP) < floor_max_angle:
		# The wall was actually a slope
		return

	# Move to collision
	var remainder = result.get_remainder()
	motion_transform = motion_transform.translated(result.get_travel())

	var step_up = player_stats.max_step_height * Vector3.UP
	parameters.from = motion_transform
	parameters.motion = step_up
	PhysicsServer3D.body_test_motion(get_rid(), parameters, result)
	motion_transform = motion_transform.translated(result.get_travel())
	var step_up_distance = result.get_travel().length()

	parameters.from = motion_transform
	parameters.motion = remainder
	PhysicsServer3D.body_test_motion(get_rid(), parameters, result)
	motion_transform = motion_transform.translated(result.get_travel())

	parameters.from = motion_transform;
	parameters.motion = Vector3.DOWN * step_up_distance

	if PhysicsServer3D.body_test_motion(get_rid(), parameters, result) == false:
		return

	motion_transform = motion_transform.translated(result.get_travel())

	var surfaceNormal = result.get_collision_normal(0)
	if (surfaceNormal.angle_to(Vector3.UP) > floor_max_angle): return

	velocity.y = player_stats.step_up_energy
	global_position.y = move_toward(global_position.y, motion_transform.origin.y, player_stats.step_acceleration * delta);
