extends Command

enum Direction{LEFT, RIGHT}

@export var strafe_direction: Direction

var velocity_cached: Vector3
var direction: Direction = Direction.LEFT

func _enter() -> void:
	exclusive = true
	velocity_cached = player.velocity
	player.velocity_overridden = true

	var dash_timer: Timer = Utilities.add_timer(true, player_stats.dash_duration)
	await dash_timer.timeout

	player.velocity = velocity_cached
	player.velocity_overridden = false

	exclusive = false


func _physics_process(_delta: float) -> void:
	var dash_direction: Vector3

	match strafe_direction:
		Direction.LEFT:
			dash_direction = (-player.transform.basis.x - player.transform.basis.z).normalized()
		Direction.RIGHT:
			dash_direction = (player.transform.basis.x - player.transform.basis.z).normalized()

	player.velocity = dash_direction * player_stats.strafe_strength
