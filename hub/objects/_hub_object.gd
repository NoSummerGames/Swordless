class_name HubObject
extends Node3D

signal interacted
signal user_input
signal state_changed

@export var visual_instance: VisualInstance3D
@export var states: DataSet

var fresh: bool = true:
	set(value):
		fresh = value
		if value == true:
			current_state = states.grab("FRESH")

var quiet: bool = false:
	set(value):
		quiet = value
		if value == true:
			current_state = states.grab("QUIET")

var busy: bool = false:
	set(value):
		busy = value
		if value == true:
			current_state = states.grab("BUSY")
		else:
			if fresh == true:
				current_state = states.grab("FRESH")
			else:
				current_state = states.grab("IDLE")

@onready var current_state: Resource:
	set(value):
		current_state = value
		emit_signal("state_changed", current_state)


func _init() -> void:
	user_input.connect(_on_user_input)
	state_changed.connect(_on_state_changed)


func _enter_tree() -> void:
	call_deferred("_setup")


func _setup() -> void:
	match fresh:
		false:
			current_state = states.grab("IDLE")
		true:
			current_state = states.grab("FRESH")


func _on_user_input(input: int) -> void:
	if input == Data.Inputs.PRESSED:
		emit_signal("interacted", self)


func _on_state_changed(_current: HubObjectState) -> void:
	pass
