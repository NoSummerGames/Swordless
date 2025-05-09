extends PlayerComponent

enum Methods {ACTIVE, PASSIVE}

@export var breaking_method: Methods = Methods.PASSIVE

@export var player_area: Area3D
@export var command_controller: CommandController
@export var freeze_component: FreezeComponent

var monitored_seals: Array[Seal]
var magnets: Array[SealMagnet]

# Callable method to remove a seal
var seal_remove: Callable = func(area: Area3D) -> void: if area is Seal: monitored_seals.erase(area)

func _ready() -> void:
	player_area.area_entered.connect(_on_area_entered)
	player_area.area_exited.connect(seal_remove)

	command_controller.command_entered.connect(_on_command_entered)


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

	# Reset player commands
	command_controller.specials_count.clear()

	if command_controller.current_command is DashCommand:
		var dash_command: DashCommand = command_controller.current_command
		dash_command.dash_timer.timeout.emit()

	for command: Command in command_controller.active_commands:
		command.cooling_down = false

	# Add a magnet to attract player
	var magnet: SealMagnet = SealMagnet.new(seal)
	magnets.append(magnet)
	add_child(magnet)


func _on_command_entered(command: Command) -> void:
	# If an command is entered and in active commands,
	if command in command_controller.active_commands and not monitored_seals.is_empty():
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
