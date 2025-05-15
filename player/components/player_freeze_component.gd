class_name FreezeComponent
extends PlayerComponent

var timer: Timer

func _ready() -> void:
	await get_tree().process_frame
	Engine.time_scale = 1.0 * player_stats.game_speed

func freeze() -> void:
	var scale: float = min(player_stats.freeze_scale, 0.1)
	Engine.time_scale = scale * player_stats.game_speed
	var duration: float = player_stats.freeze_duration
	timer = Utilities.add_timer(true, duration * scale)
	await timer.timeout
	Engine.time_scale = 1.0 * player_stats.game_speed

func unfreeze() -> void:
	if timer:
		timer.timeout.emit()
