class_name ActionDash
extends Action

var velocity_cached: Vector3
var dash: DashObject

func _enter() -> void:
	velocity_cached = player.velocity
	player.velocity_overridden = true

	dash = DashObject.new()
	dash.target = player
	set_dash_values()

	add_child(dash)

func _execute(_delta: float) -> void:
	await Utilities.add_timer(true, player_stats.dash_duration)
	player.velocity_overridden = false
	player.velocity = velocity_cached
	if dash != null:
		dash.queue_free()
	_exit()


func set_dash_values() -> void:
	var direction: Vector3 = get_dash_input()
	print(direction)
	dash.direction = direction
	dash.strength = -direction.z  * player_stats.dash_strength + abs(direction.x) * player_stats.strafe_strength

func get_dash_input() -> Vector3:
	var lateral_input: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var forward_input: float = -Input.get_action_strength("forward")
	var direction: Vector3 = Vector3(
		snapped(lateral_input, player_stats.dash_direction_snap) as float,
		0,
		snapped(forward_input, player_stats.dash_direction_snap) as float
		)
	if not direction.is_zero_approx():
		if Input.get_action_strength("backward") > 0:
			if direction.x > 0:
				return Vector3.RIGHT
			elif direction.x < 0:
				return Vector3.LEFT
		return direction
	else:
		return Vector3.FORWARD

