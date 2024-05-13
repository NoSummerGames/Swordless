@tool
extends EditorPlugin

signal playing_changed

var toolbox: Control
var playing: bool = false

func _enter_tree() -> void:
	toolbox = preload("res://addons/csg_toolbox/toolbox_scene.tscn").instantiate()
	add_control_to_bottom_panel(toolbox, "CSG Toolbox")
	toolbox.csg_added.connect(_on_csg_added)
	toolbox.material_changed.connect(_on_material_changed)
	toolbox.part_added.connect(_on_part_added)
	toolbox.part_tester_opened.connect(_on_part_tester_opened)
	toolbox.level_tester_opened.connect(_on_level_tester_opened)
	make_bottom_panel_item_visible(toolbox)

func _exit_tree() -> void:
	remove_control_from_bottom_panel(toolbox)

func _process(delta: float) -> void:
	if EditorInterface.is_playing_scene() != playing:
		make_bottom_panel_item_visible(toolbox)
		playing = not playing

func _on_csg_added(csg: Node3D) -> void:
	var current_scene = EditorInterface.get_edited_scene_root()
	if current_scene != null and current_scene is Node3D:
		current_scene.add_child(csg)
		csg.owner = current_scene
		EditorInterface.get_selection().clear()
		EditorInterface.get_selection().add_node(csg)

func _on_material_changed(mat: StandardMaterial3D) -> void:
	var selection = EditorInterface.get_selection()
	if selection != null:
		var selected = selection.get_selected_nodes()
		for node in selected:
			if node is CSGShape3D and not node is CSGCombiner3D or node is ProtoRamp:
					node.material = mat

func _on_part_added() -> void:
	var part = Part.new()
	part.name = "Part"
	var scene = PackedScene.new()
	var result = scene.pack(part)

	var dialog = EditorFileDialog.new()
	dialog.file_mode = 4
	dialog.show_hidden_files = false
	dialog.display_mode = 1
	dialog.add_filter("*.tscn, *.scn", "Scenes")

	dialog.file_selected.connect(_on_save_confirmed.bind(scene))
	EditorInterface.popup_dialog_centered_ratio(dialog, 0.4)

func _on_save_confirmed(path: String, scene: PackedScene):
	var error = ResourceSaver.save(scene, path)
	var file_system = EditorInterface.get_resource_filesystem()
	file_system.scan()
	EditorInterface.open_scene_from_path(path)
	var node = EditorInterface.get_edited_scene_root()
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(node)


func _on_part_tester_opened():
	EditorInterface.open_scene_from_path("res://addons/csg_toolbox/testers/part_tester.tscn")

func _on_level_tester_opened():
	EditorInterface.open_scene_from_path("res://addons/csg_toolbox/testers/level_tester.tscn")
