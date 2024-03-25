class_name Player
extends CharacterBody3D

signal restarted

## FIXME : added for testing purpose before having a proper "paths finding" script
@export var path_for_testing_purpose: Path3D

@export var player_stats: PlayerStatsResource:
	set(value):
		player_stats = value
		if value != player_stats:
			_update_player_stats(value)

var current_action: Action:
	set(value):
		current_action = value
		var label: Label3D = $Label3D
		label.text = value.name

var floor_raycast: RayCast3D

var velocity_overridden: bool = false
var direction: Vector3
var acceleration: float:
	get:
		if current_action.override_acceleration:
			return current_action.custom_acceleration
		elif is_almost_on_floor():
			return player_stats.ground_acceleration
		else:
			return player_stats.air_acceleration

@onready var coyote_timer: Timer = Timer.new()

@onready var forward_speed: float = player_stats.forward_speed :
	get:
			return current_action.speed_factor * player_stats.forward_speed

@onready var speed: float = player_stats.speed:
	get:
			return current_action.speed_factor * player_stats.speed

func _ready() -> void:
	add_child(coyote_timer)
	coyote_timer.one_shot = true

	## FIXME : added for testing purpose before having a proper "paths finding" script
	position = path_for_testing_purpose.curve.get_point_position(0)

func _physics_process(delta: float) -> void:
	if not velocity_overridden:
		var prev_velocity : Vector3 = velocity
		velocity.y += -player_stats.gravity * delta
		velocity.x = lerp(prev_velocity.x, direction.normalized().x * speed, acceleration * delta)
		velocity.z = lerp(prev_velocity.z, direction.normalized().z * forward_speed, player_stats.ground_acceleration * delta)
	move_and_slide()


func _update_player_stats(value: PlayerStatsResource) -> void:
	# Update children who needs player_stats with the current player_stats if changed
	for child: Node in get_tree().get_nodes_in_group("player_components"):
		for property: Dictionary in child.get_property_list():
			var property_name: StringName = property.name
			if property_name == "player_stats":
				set(property_name, value)

func is_almost_on_floor() -> bool:
	if coyote_timer != null:
		if not coyote_timer.is_stopped():
			return true
		else:
			if floor_raycast.is_colliding() or is_on_floor():
				coyote_timer.start(player_stats.coyote_time)
				return true
			else:
				return false
	else:
		return false
