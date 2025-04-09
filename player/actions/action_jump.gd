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
	timer.wait_time = player_stats.jump_time
	timer.start()

func _execute(delta: float) -> void:
	if not timer.is_stopped():
		if Input.is_action_just_released("jump") and timer.time_left >= player_stats.half_jump_timer:
			timer.start(player_stats.half_jump_timer)

		var strength: float = remap(timer.time_left, player_stats.jump_time, 0.0, start_scale, end_scale)
		player.action_velocity = player.up_direction * player_stats.jump_strength * strength
	else:
		_exit()
