extends Node3D

@export var player: Player
@export var body: MeshInstance3D
@export var action_label: Label3D
var action

func _ready() -> void:
	Utilities.debug_changed.connect(_on_debug_changed)

func _process(delta: float) -> void:
	if Utilities.debug == true:
		if player.current_action !=  action:
			action = player.current_action
			action_label.text = action.name
			body.mesh.material.albedo_color = action.debug_color

func _on_debug_changed(debug: bool):
	if debug == true:
		action_label.show()
		body.mesh.material.albedo_color = player.current_action.debug_color
	else:
		action_label.hide()
		body.mesh.material.albedo_color = Color.WHITE
