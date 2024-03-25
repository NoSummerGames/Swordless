class_name DashObject
extends Node

var target: Player
var direction: Vector3
var strength: int

func _physics_process(delta: float) -> void:
	target.velocity = lerp(target.velocity, direction * strength, target.player_stats.dash_acceleration * delta)
