class_name ActionJump
extends Action
@onready var timer: Timer = Timer.new()

var start_scale: float = 1.0
var end_scale: float = 0.0

func _ready() -> void:
	add_child(timer)
	timer.one_shot = true

func _enter() -> void:
	# Reset gravity, especially for double jumping
	player.gravity = Vector3.ZERO
	#player.action_velocity += player.up_direction * player_stats.jump_strength
	timer.wait_time = player_stats.jump_time
	timer.start()

func _execute(delta: float) -> void:
	if not timer.is_stopped():
		var strength: float = remap(timer.time_left, player_stats.jump_time, 0.0, start_scale, end_scale)
		player.action_velocity = player.up_direction * player_stats.jump_strength * strength
	else:
		_exit()
