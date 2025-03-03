class_name HubObject
extends Area3D

# Input signals
signal hovered
signal interacted
signal exited

# State signals
signal available
signal unavailable

var new: bool = true

var busy: bool = false:
	set(value):
		busy = value
		if busy:
			unavailable.emit()
		else:
			available.emit()
