class_name DashObject
extends Node

var target: Player
var direction: Vector3
var strength: int

func _physics_process(_delta: float) -> void:
	target.velocity = direction * strength
