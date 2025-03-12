class_name Seal
extends Area3D

signal broke

func _ready() -> void:
	broke.connect(_break)

func _break(direction: Vector3) -> void:
	pass
