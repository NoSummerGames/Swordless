class_name InputColorComponent
extends ComponentNode

signal color_changed

@export var input_component: InputComponent

var master_state: HubObjectState

var selected: bool = false:
	set(value):
		selected = value
		current_color = master_state.get_color(value)


@onready var current_color: Color = Color.TRANSPARENT:
	set(value):
		current_color = value
		emit_signal("color_changed", value)


func _setup() -> void:
	master.user_input.connect(_on_master_user_input)

func _on_master_state_changed(current: HubObjectState) -> void:
	master_state = current
	current_color = master_state.get_color(selected)

func _on_master_user_input(input: int) -> void:
	match input:
		Data.Inputs.SELECTED: selected = true
		Data.Inputs.UNSELECTED: selected = false
