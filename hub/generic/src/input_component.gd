class_name InputComponent
extends HubComponent

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	target.input_event.connect(_on_input_event)

	target.mouse_entered.connect(target.hovered.emit)
	target.mouse_exited.connect(target.exited.emit)

	target.available.connect(func() -> void: target.input_ray_pickable = true)
	target.unavailable.connect(func() -> void: target.input_ray_pickable = false)


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("hub_activate"):
		target.interacted.emit()
