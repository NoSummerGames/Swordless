class_name Action
extends AbstractAction

@export_group("Properties")
@export var disabled: bool
@export var override_acceleration: bool
@export var prioritary: bool
@export var speed_factor: float = 1
@export var exclusive: bool = false
@export var disable_sprint: bool = false
@export var repeatable: bool = false

@export_group("Properties parameters")
@export var custom_acceleration: float

@export_group("Conditions", "cond_")
@export var cond_match_input: bool
@export var cond_on_ground: bool
@export var cond_in_air: bool
@export var cond_on_wall: bool
@export var cond_special: bool
@export var cond_cooldown: bool
@export var cond_strictly_on_ground: bool

@export_group("Conditions parameters")
@export var input_required: Data.Actions
@export var cooldown_time: float

@export var debug_color: Color

# Dictionary keys must be matching the above boolean var names
var conditions : Dictionary = {
	"cond_match_input" : func() -> bool: return false if input_required not in input else true,
	"cond_on_ground" : func() -> bool: return true if player.is_almost_on_floor() or not player.coyote_timer.is_stopped() else false,
	"cond_strictly_on_ground" : func() -> bool: return player.is_on_floor(),
	"cond_in_air": func() -> bool: return !player.is_on_floor(),
	"cond_on_wall": func() -> bool: return true if player.is_on_wall_only() and \
	absf(player.get_last_slide_collision().get_normal().x) > player_stats.wall_jump_angle_range and \
	signf(player.get_last_slide_collision().get_normal().x) != signf(wall_jumped_normal) else false,
	"cond_special": func() -> bool:
		return false if self in specials_count or specials_count.size() > player_stats.max_specials else true,
	"cond_cooldown": func() -> bool: return cooldown_over
	}

@onready var contexts: Array[Callable] = [
	func() -> bool: return false if disabled else true,
	func() -> bool: return false if not prioritary and priority_time == true else true,
	func() -> bool:
		if get("exclusive") :
			return true
		elif get("current_action").exclusive and done == false:
			return false
		else:
			return true
]

var cooldown_over: bool = true

func _physics_process(delta: float) -> void:
	current_action._execute(delta)

	for context: Callable in contexts:
		if context.call() == false:
			return

	if current_action != self or get("current_action").repeatable:
		if self.cond_match_input == true and input_required not in input:
			pass
		else:
			_check_conditions()


func _check_conditions() -> void:
	for property: Dictionary in get_property_list():
		var property_name : String = property.name
		if property_name.begins_with("cond_") and property.type == TYPE_BOOL:
			if self.get(property_name) == true:
				var condition: Callable = conditions[property_name]
				if condition.call() == false:
					return
			else:
				continue

	set_current_action()


func set_current_action() -> void:
	input.clear()
	_enter()
	current_action._exit()
	current_action = self

	player.current_action = current_action
	player.coyote_timer.stop()

	if current_action.exclusive:
		done = false

	if current_action.cond_special:
		specials_count.append(self)

	if current_action.cond_cooldown:
		cooldown_over = false
		var timer: Timer = Utilities.add_timer(true, cooldown_time)
		await timer.timeout
		cooldown_over = true

	if current_action.prioritary:
		priority_time = true
		var timer: Timer = Utilities.add_timer(true, player_stats.priority_buffer)
		await timer.timeout
		priority_time = false

func _enter() -> void:
	pass
func _execute(_delta: float) -> void:
	pass

func _exit() -> void:
	done = true
	if self != actions_controller.default_action:
		current_action = actions_controller.default_action
		player.current_action = current_action
