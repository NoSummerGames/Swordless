class_name HubObjectState
extends CustomResource


@export var is_ray_pickable: bool = true
@export var selected_color_res: GameColor
@export var unselected_color_res: GameColor

func get_color(is_selected: bool) -> Color:
	if is_selected:
		if selected_color_res.color != null:
			return selected_color_res.color
		else:
			printerr("{} has no selected color resource. Returned Color.RED instead.".format([resource_path]))
			return Color.RED
	else:
		if unselected_color_res.color != null:
			return unselected_color_res.color
		else:
			printerr("{} has no selected color resource. Returned Color.RED instead.".format([resource_path]))
			return Color.RED

