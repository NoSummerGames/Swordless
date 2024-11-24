class_name FreezeComponent
extends PlayerComponent

var disabled: bool = true

@onready var input_component: PlayerInputComponent = %InputComponent

func _ready() -> void:
	input_component.command_input.connect(_on_player_input)

func _on_player_input(action: Data.Actions, _params: Data.ActionParams) -> void:
	if not disabled:
		if action == Data.Actions.FREEZE:
			var scale: float = min(player_stats.freeze_scale, 0.1)
			Engine.time_scale = scale
			var duration: float = player_stats.freeze_duration
			var timer: Timer = Utilities.add_timer(true, duration * scale)
			await timer.timeout
			Engine.time_scale = 1.0
