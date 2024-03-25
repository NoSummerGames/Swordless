class_name ComponentNode
extends Node

@export var master: HubObject

func _enter_tree() -> void:
	call_deferred("_setup")
	master.state_changed.connect(_on_master_state_changed)

func _setup() -> void:
	pass

func _on_master_state_changed(_current: HubObjectState) -> void:
	pass
