class_name ComponentControl
extends Control

@export var master: HubObject
@export var main_theme: Theme

func _enter_tree() -> void:
	call_deferred("_setup")
	master.state_changed.connect(_on_master_state_changed)

func _setup():
	pass

func _on_master_state_changed(_state: HubObjectState) -> void:
	pass
