class_name Component3D
extends Node3D

@export var master: HubObject

func _enter_tree() -> void:
	call_deferred("_setup")
	master.state_changed.connect(_on_master_state_changed)

func _setup() -> void:
	pass

func _on_master_state_changed(_state: HubObjectState) -> void:
	pass
