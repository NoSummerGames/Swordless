@tool
extends Control

signal csg_added(csg: CSGShape3D)
signal material_changed(mat: StandardMaterial3D)
signal part_added
signal part_tester_opened
signal level_tester_opened

@export var create_buttons: Control
@export var material_buttons: Control
@export var default_material: StandardMaterial3D
@export var materials: Array[StandardMaterial3D]

var index : Dictionary = {
	"Box": {"type": CSGBox3D,
			"attributes" : {"position" : Vector3(0.0, 0.5, -0.5)}
			},

	"Cylinder": {"type": CSGCylinder3D,
			"attributes" : {"position" : Vector3(0.0, 1.0, 0.0)}
			},

	"Mesh": {"type": CSGMesh3D,
			"attributes" : {}
			},

	"Polygon": {"type": CSGPolygon3D,
			"attributes" : {}
			},

	"Ramp": {"type": ProtoRamp,
			"attributes" : {"rotation" :Vector3(0, deg_to_rad(180), 0)}
			},

	"Sphere": {"type": CSGSphere3D,
			"attributes" : {}
			},

	"Stairs": {"type": ProtoRamp,
			"attributes" : {
				"rotation" : Vector3(0, deg_to_rad(180), 0),
				"type": 1}
			},

	"Torus": {"type": CSGTorus3D,
			"attributes" : {}
			},

	"Combiner": {"type": CSGCombiner3D,
			"attributes" : {}
			},

	"Part": {"type": Part,
			"attributes" : {}
			}
	}

func _enter_tree() -> void:
	for child in material_buttons.get_children():
		if child is ToolBoxMaterialButton and not child.pressed.is_connected(_on_material_button_pressed):
			child.pressed.connect(_on_material_button_pressed.bind(child.button_material))

func _on_create_button_pressed(button) -> void:
	match button:
		"Part Tester":
			emit_signal("part_tester_opened")
			return
		"Level Tester":
			emit_signal("level_tester_opened")
			return

	if index[button]["type"] == Part:
		emit_signal("part_added")
		return

	var object: Node3D = index[button]["type"].new()
	for property in index[button]["attributes"].keys():
		object.set(property, index[button]["attributes"][property])
	if object.get("smooth_faces") != null:
		object.smooth_faces = false
	if object.get("use_collision") != null:
		object.use_collision = true

	if object is CSGCombiner3D:
		if object is ProtoRamp:
			object.material = default_material
	else:
		object.material = default_material
	emit_signal("csg_added", object)

func _on_material_button_pressed(mat: StandardMaterial3D) -> void:
	emit_signal("material_changed", mat)
