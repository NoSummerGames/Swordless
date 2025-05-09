class_name Player
extends CharacterBody3D

signal reached_exit
signal died
signal exited_path

const DOWNWARD_LIMIT: float = -0.05
## FIXME : added for testing purpose before having a proper "paths finding" script
@export var path: Path3D
@export var player_stats: PlayerStatsResource

var velocity_overridden: bool = false
var direction: Vector3
var gravity: Vector3 = Vector3.DOWN
var command_velocity: Vector3 = Vector3.ZERO
var desired_vel: Vector3
var acceleration: float:
	get:
		if command_controller.current_command.override_acceleration:
			return command_controller.current_command.custom_acceleration
		elif command_controller.current_command.space == Command.Space.AIR:
			return player_stats.air_acceleration
		return player_stats.ground_acceleration

var on_floor: bool = true

var floor_normal: Vector3 = Vector3.UP
var can_sprint: bool = true

var path_progression: float = 0.0

var command_controller: CommandController

@onready var rid: RID = get_rid()

@onready var body: MeshInstance3D = %_PlayerMesh
@onready var area: Area3D = %PlayerArea
@onready var speed: float = player_stats.speed:
	get:
		if Input.is_action_pressed("sprint") and can_sprint and command_controller.current_command.disable_sprint == false:
			return command_controller.current_command.speed_factor * player_stats.sprint_speed
		else:
			return command_controller.current_command.speed_factor * player_stats.speed

func _ready() -> void:
	area.area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	on_floor = _is_almost_on_floor()

	if not velocity_overridden:
		var floor_angle: float = clamp(1.0 - floor_normal.z, player_stats.min_slope_speed, 1.0)

		if floor_normal.z <= DOWNWARD_LIMIT and on_floor:
			var forward_normal: Vector3 = floor_normal.cross(global_basis.x)
			var angle: float = forward_normal.angle_to(-global_basis.z)
			var new_direction: Vector3 = direction.normalized().rotated(global_basis.x, -angle)
			desired_vel = lerp(desired_vel, new_direction * speed, acceleration * delta)
		else:
			desired_vel = lerp(desired_vel, direction.normalized() * Vector3(1, 0, 1) * speed * floor_angle, acceleration * delta)


		velocity = desired_vel - gravity + command_velocity

		if test_stairs_up(delta) == true:
			velocity *= player_stats.stairs_speed

	move_and_slide()

	if gravity.y > 100:
		died.emit()

	command_velocity = Vector3.ZERO

func _is_almost_on_floor() -> bool:
	var motion: Vector3 = -global_basis.y * player_stats.floor_detection_margin
	var result : PhysicsTestMotionResult3D = Utilities.test_collision(get_rid(), global_transform, motion)

	if result.get_collision_count() > 0:
		for i: int in result.get_collision_count():
			var normal: Vector3 = result.get_collision_normal(i)
			if normal.y > 0.5:
				floor_normal = normal
				return true

	return false

func test_stairs_up(delta: float) -> bool:
	# Minor rework of "Stairs Character" script by Andicraft

	# Test collision
	var motion_transform: Transform3D = global_transform
	var motion_velocity: Vector3 = direction * speed * delta
	var result : PhysicsTestMotionResult3D = Utilities.test_collision(rid, motion_transform, motion_velocity)
	if result.get_collision_count() == 0:
		# No wall was hit
		can_sprint = true
		return false


	var angle: float = result.get_collision_normal(0).angle_to(global_basis.y)
	if angle < floor_max_angle:
		# The wall was actually a slope
		return false

	can_sprint = false

	# Move to collision
	var remainder: Vector3 = result.get_remainder()
	motion_transform = motion_transform.translated(result.get_travel())

	# Raise the motion transform according to max_step_height
	var step_up: Vector3 = player_stats.max_step_height * global_basis.y
	result = Utilities.test_collision(rid, motion_transform, step_up)

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
	result = Utilities.test_collision(rid, motion_transform, remainder)
	if result.get_collision_count() > 0:
		# Check if it's an head-on collision
		var dot: float = result.get_collision_normal(0).dot(global_basis.z)
		if dot > player_stats.death_accuracy:
			emit_signal("died")


	motion_transform = motion_transform.translated(result.get_travel())

	# Move down the step
	var step_down: Vector3 = -global_basis.y * step_up_distance
	result = Utilities.test_collision(rid, motion_transform, step_down)
	if result.get_collision_count() == 0:
		return false

	motion_transform = motion_transform.translated(result.get_travel())

	# Check if the step is not a wall
	if result.get_collision_count() > 0:
		var surface_normal: Vector3 = result.get_collision_normal(0)
		if (surface_normal.angle_to(global_basis.y) > floor_max_angle):
			# Check if the wall can be slided down to a step
			var deviation: Vector3 = result.get_remainder().slide(surface_normal)
			result = Utilities.test_collision(rid, motion_transform, deviation)
			if result.get_collision_count() == 0:
				return false
			else:
				motion_transform = motion_transform.translated(result.get_travel())

	global_position += (motion_transform.origin - global_position) * player_stats.stairs_speed
	return true

func _on_area_entered(area_entered: Area3D) -> void:
	if area_entered is ExitArea:
		reached_exit.emit()

func _on_player_exited_path() -> void:
	exited_path.emit()
