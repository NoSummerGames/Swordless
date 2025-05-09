class_name DashCommand
extends Command

var velocity_cached: Vector3
var dash_timer: Timer

func _enter() -> void:
	exclusive = true
	velocity_cached = player.velocity
	player.velocity_overridden = true

	dash_timer = Utilities.add_timer(true, player_stats.dash_duration)
	await dash_timer.timeout

	player.velocity = velocity_cached
	player.velocity_overridden = false

	exclusive = false


func _physics_process(_delta: float) -> void:
	player.velocity = -player.global_basis.z * player_stats.dash_strength
