extends Control

@export var target: Node
@export var radius: float = 1.0
@export var color: Color = Color.RED


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	call_deferred("queue_redraw")


func _draw() -> void:
	var target_pos = get_viewport().get_camera_3d().unproject_position(target.point_a)
	var target_pos_b = get_viewport().get_camera_3d().unproject_position(target.point_b)
	draw_circle(target_pos, radius, color)
	draw_circle(target_pos_b, radius, color)
	
