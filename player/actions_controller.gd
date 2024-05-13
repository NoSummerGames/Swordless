class_name ActionsController
extends AbstractAction

@export var input_component: PlayerInputComponent
@export var air_default_action: Action
@export var ground_default_action: Action

@onready var default_action: Action:
	get:
		if player.is_on_floor():
			return ground_default_action
		else:
			return air_default_action

func _init() -> void:
	actions_controller = self

func _ready() -> void:
	current_action = default_action
	player.current_action = default_action
	input_component.command_input.connect(_on_command_input)

func _physics_process(_delta: float) -> void:
	if player.is_almost_on_floor():
		specials_count.clear()

	if input.size() > player_stats.input_buffer :
		input.pop_front()

func _on_command_input(_input: Data.Actions, _action_param: Data.ActionParams) -> void:
	if _action_param == Data.ActionParams.END:
		has_slided = false
	if _input == Data.Actions.SLIDE and has_slided == true:
		pass
	else:
		input.append(_input)
	action_param = _action_param
	input.append(Data.Actions.NONE)
