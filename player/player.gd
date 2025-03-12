class_name Player
extends CharacterBody3D

signal reached_exit
signal died
signal exited_path

## FIXME : added for testing purpose before having a proper "paths finding" script
@export var path: Path3D
@export var player_stats: PlayerStatsResource


var current_action: Action
var actions: Array[Action]

var velocity_overridden: bool = false
var direction: Vector3
var desired_vel: Vector3
var acceleration: float:
	get:
		if current_action.override_acceleration:
			return current_action.custom_acceleration
		elif current_action.space == Action.Spaces.GROUND :
			return player_stats.ground_acceleration
		elif current_action.space == Action.Spaces.AIR:
			return player_stats.air_acceleration
		return player_stats.ground_acceleration

var on_floor: bool = true

var floor_normal: Vector3 = Vector3.UP

@onready var body: MeshInstance3D = %_PlayerMesh
@onready var area: Area3D = %PlayerArea
@onready var coyote_timer: Timer = %CoyoteTimer
@onready var speed: float = player_stats.speed:
	get:
		if Input.is_action_pressed("sprint") and current_action.disable_sprint == false:
			return current_action.speed_factor * player_stats.sprint_speed
		else:
			return current_action.speed_factor * player_stats.speed

func _ready() -> void:
	area.area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if not velocity_overridden:

		var floor_angle: float = clamp(1.0 - get_floor_normal().z, player_stats.min_slope_speed, 1.0)

		if not is_on_floor():
			velocity.y -= player_stats.gravity * delta

		desired_vel.z = lerp(desired_vel.z, direction.normalized().z * speed * floor_angle, acceleration * delta)
		desired_vel.x = lerp(desired_vel.x, direction.normalized().x * speed, acceleration * delta)
		velocity.z = desired_vel.z
		velocity.x = desired_vel.x

		velocity = test_stairs_up(delta)

	move_and_slide()


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
				floor_normal = normal
				return true

	if on_floor == true:
		coyote_timer.start(player_stats.coyote_time)

	on_floor = false
	return false

func test_stairs_up(delta: float) -> Vector3:
	# Minor rework of "Stairs Character" script by Andicraft
	var motion_velocity: Vector3 = direction * speed * delta

	# Test collision
	var motion_transform: Transform3D = global_transform
	var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
	parameters.from = motion_transform
	parameters.motion = motion_velocity
	var result : PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
	if PhysicsServer3D.body_test_motion(get_rid(), parameters, result) == false:
		# No wall was hit
		return velocity

	var angle: float = result.get_collision_normal(0).angle_to(global_basis.y)
	if angle < floor_max_angle:
		# The wall was actually a slope
		return velocity

	# Move to collision
	var remainder: Vector3 = result.get_remainder()
	motion_transform = motion_transform.translated(result.get_travel())

	# Raise the motion transform according to max_step_height
	var step_up: Vector3 = player_stats.max_step_height * global_basis.y
	parameters.from = motion_transform
	parameters.motion = step_up
	PhysicsServer3D.body_test_motion(get_rid(), parameters, result)

	# motion_transform will be full length if no ceiling was met
	var step_up_distance: float
	var ceiling_remainder: Vector3 = result.get_remainder()
	if ceiling_remainder != Vector3.ZERO:
		# Deviate the trajectory if a ceiling is met
		var deviation: Vector3 = ceiling_remainder.slide(result.get_collision_normal(0))

		motion_transform = motion_transform.translated(result.get_travel() + deviation)
		step_up_distance = (result.get_travel() + deviation).length()
	else:
		motion_transform = motion_transform.translated(result.get_travel())
		step_up_distance = result.get_travel().length()

	# Move in its original direction with remaining velocity
	parameters.from = motion_transform
	parameters.motion = remainder

	if PhysicsServer3D.body_test_motion(get_rid(), parameters, result) == true:
		# Check if it's an head-on collision
		var dot: float = result.get_collision_normal(0).dot(global_basis.z)
		if dot > player_stats.death_accuracy:
			emit_signal("died")


	motion_transform = motion_transform.translated(result.get_travel())

	# Move down the step
	parameters.from = motion_transform
	parameters.motion = -global_basis.y * step_up_distance

	var moved_down: bool = PhysicsServer3D.body_test_motion(get_rid(), parameters, result)
	if moved_down == false:
		return velocity
	motion_transform = motion_transform.translated(result.get_travel())

	# Check if the step is not a wall
	if result.get_collision_count() > 0:
		var surface_normal: Vector3 = result.get_collision_normal(0)
		if (surface_normal.angle_to(global_basis.y) > floor_max_angle):
			# Check if the wall can be slided down to a step
			var deviation: Vector3 = result.get_remainder().slide(surface_normal)
			parameters.from = motion_transform
			parameters.motion = deviation
			if PhysicsServer3D.body_test_motion(get_rid(), parameters, result) == false:
				return velocity
			else:
				motion_transform = motion_transform.translated(result.get_travel())

	global_position += (motion_transform.origin - global_position) * player_stats.stairs_speed
	return velocity * player_stats.stairs_speed

func _on_area_entered(area_entered: Area3D) -> void:
	if area_entered is ExitArea:
		emit_signal("reached_exit")

func _on_player_exited_path() -> void:
	emit_signal("exited_path")
