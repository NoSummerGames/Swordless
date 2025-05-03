extends PlayerComponent

@export var input_component: PlayerInputComponent

var initial_energy: float = 1
var dead: bool = false

func _ready() -> void:
	player.died.connect(_on_player_dead)
	player.died.connect(set.bind("dead", true))

func _physics_process(delta: float) -> void:
	if dead:
		initial_energy = lerp(initial_energy, 0.0, 0.5 * delta)
		player.velocity = player.global_basis.z * max(0, initial_energy)

func _on_player_dead() -> void:
	player.path_progression = player.path.curve.get_closest_offset(player.global_position)
	input_component.disabled = true
	player.velocity_overridden = true
