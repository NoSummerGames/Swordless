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
	var timer = await Utilities.add_timer(true, player_stats.dash_duration)
	await timer.timeout
	if is_instance_valid(dash):
		dash.queue_free()
	player.velocity = velocity_cached
	player.velocity_overridden = false
	_exit()


func set_dash_values() -> void:
	var direction: Vector3 = get_dash_input()
	dash.direction = direction
	dash.strength = -direction.z  * player_stats.dash_strength + abs(direction.x) * player_stats.strafe_strength
	#dash.strength = player_stats.dash_strength
#
func get_dash_input() -> Vector3:
	var lateral_input: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var forward_input: float = -Input.get_action_strength("forward")
	var direction: Vector3 = (Vector3(
		snapped(lateral_input, player_stats.dash_direction_snap) as float,
		0,
		snapped(forward_input, player_stats.dash_direction_snap) as float
		) + Vector3.FORWARD).normalized()
	if not direction.is_zero_approx():
		if Input.get_action_strength("down") > 0:
			if direction.x > 0:
				return Vector3.RIGHT
			elif direction.x < 0:
				return Vector3.LEFT
		return direction
	else:
		return Vector3.FORWARD

