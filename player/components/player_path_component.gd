extends PlayerComponent

var default_direction: Vector3 = Vector3.FORWARD
var previous_direction: Vector3:
	get:
		if previous_direction == null:
			return default_direction
		else:
			return previous_direction

# FIXME : added for testing purpose before having a proper "paths finding" script
@onready var path: Path3D = player.path_for_testing_purpose
@onready var next_offset: float = player_stats.interpolation_distance
@onready var inertia: float = player_stats.path_inertia

func _physics_process(delta: float) -> void:
	player.direction = get_path_direction(delta)
	player.look_at(player.position + player.direction.rotated(Vector3.UP, PI * 2))

func get_path_direction(delta: float) -> Vector3:
	# Get the closest path "offset" to the player
	var closest_offset: float = path.curve.get_closest_offset(path.to_local(player.global_position))

	# Get its interpolated point counterpart on the path
	var point_a: Vector3 = path.curve.sample_baked(closest_offset)
	# Get an interpolated point slightly past the first
	var point_b: Vector3 = path.curve.sample_baked(closest_offset + next_offset)

	# If point_a and point_b are different (i.e. if it's not the path end), stores the direction
	# the next iteration will interpolate and return the actual path direction
	if point_a != point_b:
		var direction: Vector3 = lerp(previous_direction, point_a.direction_to(point_b), inertia * delta)
		previous_direction = direction
		return direction

	# TODO : if its the end of the path, find the next closest path
	#elif point_a == point_b and get_closest_path(paths_list) != path:
		#return get_path_direction(get_closest_path(paths_list), previous_direction, inertia, paths_list)
	#else:
		#return previous_direction

	# HACK : while waiting for the above part to be written, return the default direction:
	else:
		player.emit_signal("exited_path")
		return lerp(previous_direction, default_direction, inertia * delta)
