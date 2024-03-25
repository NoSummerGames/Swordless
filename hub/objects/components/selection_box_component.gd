class_name SelectionBox
extends ComponentControl

@export var input_color: InputColorComponent
@export var visual_instance: VisualInstance3D

var rect: Rect2
var current_color: Color:
	get:
		return input_color.current_color

var box_scale: float = main_theme.get_constant("box_scale", "SelectionBox") * 0.1
var corner_radius: float = main_theme.get_constant("corner_radius", "SelectionBox")
var line_thickness: float = main_theme.get_constant("line_thickness", "SelectionBox")

@onready var viewport: Viewport = get_viewport()
@onready var cam: Camera3D = viewport.get_camera_3d()
@onready var vi: VisualInstance3D = visual_instance

func _enter_tree() -> void:
	master.state_changed.connect(_on_master_state_changed)

func _draw() -> void:
	if current_color != Color.TRANSPARENT:
		var center_point: Vector2 = cam.unproject_position(vi.to_global(vi.get_aabb().get_center()))
		var aabb_size: Vector2 = (
			cam.unproject_position(vi.to_global(vi.get_aabb().position)) -
			cam.unproject_position(vi.to_global(vi.get_aabb().end))
			)
		var longest_axis: int = max(aabb_size.x, aabb_size.y)
		var box_size: Vector2 = Vector2(longest_axis, longest_axis)
		rect = Rect2(center_point - box_size * box_scale / 2, box_size * box_scale)
		var points: PackedVector2Array = [
			rect.position,
			rect.position + Vector2(corner_radius, 0),
			rect.position,
			rect.position + Vector2(0, corner_radius),
			rect.position + rect.size,
			rect.position + rect.size - Vector2(0, corner_radius),
			rect.position + rect.size,
			rect.position + rect.size - Vector2(corner_radius, 0)
			]
		draw_multiline(points, current_color, float(line_thickness))

func _process(_delta: float) -> void:
	queue_redraw()

func _on_master_state_changed(_state: HubObjectState) -> void:
	pass
