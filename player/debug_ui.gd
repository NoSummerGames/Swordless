extends Control

@export var target: Node3D

var previous_position: Vector3
var time: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	Utilities.debug_changed.connect(_on_debug_changed)
	target.connect("restarted", set.bind("time", 0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Utilities.debug == true:
		var current_position = target.global_position
		var current_velocity = (current_position - previous_position)/delta
		var speed = Vector3.ZERO.distance_to(Vector3(current_velocity.x, 0, current_velocity.z))
		%LabelSpeed.text = "Speed : {}".format([snappedf(speed, 0.1)], "{}")
		previous_position = current_position

		var collision_point = %DebugHeightRaycast.get_collision_point()
		var altitude = target.global_position.distance_to(collision_point)
		%LabelAltitude.text = "Altitude : {}".format([snappedf(altitude, 0.1)], "{}")

		time += delta
		%LabelTimer.text = "Timer : {}".format([snappedf(time, 0.1)], "{}")

func _on_debug_changed(debug: bool):
	if debug == true:
		show()
	else:
		hide()
