class_name Player
extends CharacterBody3D

signal exited_path
signal restarted

## FIXME : added for testing purpose before having a proper "paths finding" script
@export var path: Path3D

@export var player_stats: PlayerStatsResource:
	set(value):
		player_stats = value
		if value != player_stats:
			_update_player_stats(value)

var current_action: Action

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

@onready var speed: float = player_stats.speed:
	get:
		return current_action.speed_factor * player_stats.speed

func _ready() -> void:
	## FIXME : added for testing purpose before having a proper "paths finding" script
	position = path.curve.get_point_position(0)

func _physics_process(delta: float) -> void:
	if not velocity_overridden:
		velocity.y += -player_stats.gravity * delta
		velocity.x = lerp(velocity.x, direction.normalized().x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.normalized().z * speed, acceleration * delta)

	move_and_slide()


func _update_player_stats(value: PlayerStatsResource) -> void:
	# Update children who needs player_stats with the current player_stats if changed
	for child: Node in get_tree().get_nodes_in_group("player_components"):
		for property: Dictionary in child.get_property_list():
			var property_name: StringName = property.name
			if property_name == "player_stats":
				set(property_name, value)

func is_almost_on_floor() -> bool:
	if floor_raycast.is_colliding() or is_on_floor():
		return true
	else:
		return false
