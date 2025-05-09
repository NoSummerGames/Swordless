extends PlayerComponent

signal path_exited

var previous_up_direction: Vector3 = Vector3.UP


var default_direction: Vector3 = Vector3.FORWARD
var previous_direction: Vector3:
	get:
		if previous_direction == null:
			return default_direction
		else:
			return previous_direction

var path_up_vector: Vector3 = Vector3.UP

# FIXME : added for testing purpose before having a proper "paths finding" script
@onready var path: Path3D = player.path
@onready var next_offset: float = player_stats.interpolation_distance
@onready var stiffness: float = player_stats.path_stiffness
@onready var path_offset: float = player_stats.path_offset

func _ready() -> void:
	path_exited.connect(player._on_player_exited_path)

func _physics_process(delta: float) -> void:
	if player.on_floor:
		path_up_vector = player.floor_normal
		player.up_direction = lerp(previous_up_direction, path_up_vector, player_stats.ground_acceleration * delta)
	else:
		if player_stats.local_gravity:
			player.up_direction = previous_up_direction
		else:
			var closest_offset: float = path.curve.get_closest_offset(path.to_local(player.global_position))
			path_up_vector = path.curve.sample_baked_up_vector(closest_offset)
			player.up_direction = lerp(previous_up_direction, path_up_vector, player_stats.air_acceleration * delta)

	previous_up_direction = player.up_direction

	player.direction = get_path_direction(delta)
	const HORIZONTAL: Vector3 = Vector3(1,0,1)
	player.look_at(player.global_position + player.direction * HORIZONTAL, player.up_direction)

func get_path_direction(delta: float) -> Vector3:
	# Get the closest path "offset" to the player
	var closest_offset: float = path.curve.get_closest_offset(path.to_local(player.global_position))

	# Get its interpolated point counterpart on the path
	var point_a: Vector3 = path.curve.sample_baked(closest_offset + path_offset)
	# Get an interpolated point slightly past the first
	var point_b: Vector3 = path.curve.sample_baked(closest_offset + next_offset + path_offset)

	# If point_a and point_b are different (i.e. if it's not the path end), stores the direction
	# the next iteration will interpolate and return the actual path direction
	if point_a != point_b:
		var direction: Vector3 = lerp(previous_direction, point_a.direction_to(point_b), stiffness * delta)
		previous_direction = direction
		return direction

	# TODO : if its the end of the path, find the next closest path
	#elif point_a == point_b and get_closest_path(paths_list) != path:
		#return get_path_direction(get_closest_path(paths_list), previous_direction, stiffness, paths_list)
	#else:
		#return previous_direction

	# HACK : while waiting for the above part to be written, return the default direction:
	else:
		emit_signal("path_exited")
		return lerp(previous_direction, default_direction, stiffness * delta)
