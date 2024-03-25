extends RayCast3D

@export var player: Player

func _ready() -> void:
	player.floor_raycast = self
	target_position.y = -player.player_stats.floor_detection_margin
