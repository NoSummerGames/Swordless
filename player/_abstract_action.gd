class_name AbstractAction
extends PlayerComponent

static var input: Data.Actions:
	set(value):
		if value != input:
			input = value
		if value == Data.Actions.NONE:
			input = value

static var current_action: Action

static var action_param: Data.ActionParams

static var actions_controller: ActionsController

static var specials_count: Array[Action]

static var priority_time: bool

static var done: bool

static var has_slided: bool
