class_name ActionDash
extends Action

var velocity_cached: Vector3
var dash: DashObject
var dash_timer: Timer

func _enter() -> void:
	velocity_cached = player.velocity
	player.velocity_overridden = true

	dash = DashObject.new()
	dash.target = player
	set_dash_values()

	add_child(dash)

	dash_timer = Utilities.add_timer(true, player_stats.dash_duration)
	await dash_timer.timeout
	if is_instance_valid(dash):
		dash.queue_free()
	player.velocity = velocity_cached
	player.velocity_overridden = false

	_exit()


func set_dash_values() -> void:
	dash.direction = -player.global_basis.z
	dash.strength = player_stats.dash_strength
