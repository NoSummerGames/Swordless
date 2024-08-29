class_name InputComponent
extends ComponentNode

@export var collision_component: CollisionComponent

@onready var signals: Dictionary = {
		"mouse_entered": Callable(master, "emit_signal").bind("user_input", Data.Inputs.SELECTED),
		"mouse_exited": Callable(master, "emit_signal").bind("user_input", Data.Inputs.UNSELECTED),
		"input_event": Callable(self, "_on_input_event")
		}

func _ready() -> void:
	collision_component.collision_set.connect(_on_collision_set)


func _on_collision_set(area: Area3D) -> void:
	# Connect area signals to self input signal with arguments
	for key: StringName in signals.keys():
		var input_signal: Callable = signals.get(key)
		Signal(area, key).connect(input_signal, 1)


func _on_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and (event as InputEventMouseButton).pressed:
			master.emit_signal("user_input", Data.Inputs.PRESSED)
		elif (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and not (event as InputEventMouseButton).pressed:
			master.emit_signal("user_input", Data.Inputs.RELEASED)
