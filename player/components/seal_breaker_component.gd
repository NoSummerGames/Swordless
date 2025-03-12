extends PlayerComponent

enum Methods {ACTIVE, PASSIVE}

@export var breaking_method: Methods = Methods.PASSIVE

@export var player_area: Area3D
@export var actions_controller: ActionsController
@export var freeze_component: FreezeComponent
@export var breaking_actions: Array[Action]

var monitored_seals: Array[Seal]
var magnets: Array[SealMagnet]

# Callable method to remove a seal
var seal_remove: Callable = func(area: Area3D) -> void: if area is Seal: monitored_seals.erase(area)

func _ready() -> void:
	player_area.area_entered.connect(_on_area_entered)
	player_area.area_exited.connect(seal_remove)

	actions_controller.action_entered.connect(_on_action_entered)


func _on_area_entered(area: Area3D) -> void:
	if area is Seal:
		var seal: Seal = area
		# Freeze player whatever the method is
		freeze_component.freeze()

		monitored_seals.append(seal)

		# Break the seal by entering it if method is PASSIVE
		if breaking_method == Methods.PASSIVE:
			_break_seal(seal)


func _break_seal(seal: Seal) -> void:
	seal.broke.emit(player.velocity)

	# Reset player actions
	actions_controller.specials_count.clear()

	if player.current_action is ActionDash:
		var action_dash: ActionDash = player.current_action
		action_dash.dash_timer.timeout.emit()

	for action: Action in player.actions:
		action.cooldown_over = true

	# Add a magnet to attract player
	var magnet: SealMagnet = SealMagnet.new(seal)
	magnets.append(magnet)
	add_child(magnet)


func _on_action_entered(action: Action) -> void:
	# If an action is entered and in breaking_actions,
	if action in breaking_actions and not monitored_seals.is_empty():
		for seal: Seal in monitored_seals:
			# Unfreeze player whatever the method is to reinforce agency
			freeze_component.unfreeze()
			# Break the seal if method is ACTIVE
			if breaking_method == Methods.ACTIVE:
				_break_seal(seal)

		monitored_seals.clear()
		magnets.clear()


func _physics_process(delta: float) -> void:
	for magnet: SealMagnet in magnets:
		# Attract player and check if the magnet is still attracting
		var active: bool = magnet.attract(player, delta)
		# If not, delete it
		if not active:
			magnets.erase(magnet)
			magnet.queue_free()
