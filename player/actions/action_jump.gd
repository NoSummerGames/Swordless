class_name ActionJump
extends Action

@onready var timer: Timer = Timer.new()

func _ready() -> void:
	add_child(timer)
	timer.one_shot = true

func _enter() -> void:
	player.velocity.y = 0
	player.velocity.y += player_stats.jump_strength
	timer.wait_time = player_stats.half_jump_buffer
	timer.start()

func _execute(delta: float) -> void:
	if Input.is_action_just_released("jump") and not timer.is_stopped():
		player.velocity.y = lerpf(player.velocity.y, -player.velocity.y, player_stats.half_jump_deceleration * delta)
