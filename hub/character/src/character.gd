class_name Character
extends HubObject

enum Status{NEUTRAL, HOSTILE, FRIENDLY, DEAD, HIDDEN}

# State signals
signal status_changed(status: Status)

var status: Status = Status.NEUTRAL:
	set(value):
		status = value
		status_changed.emit(status)

@export var resource: CharacterResource


func _ready() -> void:
	_inject_dependencies()


func _inject_dependencies() -> void:
	# Add self to CharacterResource
	assert(resource)
	resource.character = self
