class_name TriggerButton
extends Button

signal trigger_pressed

@export var trigger: StringName

func _ready() -> void:
	pressed.connect(_on_self_pressed)


func _on_self_pressed() -> void:
	trigger_pressed.emit(trigger)
