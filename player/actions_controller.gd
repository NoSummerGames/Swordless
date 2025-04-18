class_name ActionsController
extends AbstractAction

signal action_entered

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
	for action: Action in get_children():
		player.actions.append(action)
		action.entered.connect(action_entered.emit.bind(action))

	current_action = default_action
	player.current_action = default_action
	input_component.command_input.connect(_on_command_input)

func _physics_process(delta: float) -> void:
	current_action._execute(delta)

	if player.is_on_floor():
		specials_count.clear()
		wall_jumped_normal = 0

	input.append(Data.Actions.NONE)

	if input.size() > player_stats.input_buffer :
		input.pop_front()

func _on_command_input(_input: Data.Actions, _action_param: Data.ActionParams) -> void:
	input.append(_input)
	action_param = _action_param
