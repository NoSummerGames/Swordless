extends Node

@export var player: Player
@export var level_generator: LevelGenerator

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		player.global_transform = Transform3D.IDENTITY
		player.emit_signal("restarted")
		if level_generator != null:
			level_generator.dirty = false
			for part in level_generator.parts:
				part.queue_free()
			level_generator.parts.clear()