@tool
extends EditorPlugin

const dialogue_editor_scene: PackedScene = preload("res://addons/dialogue_manager/scenes/dialogue_manager.tscn")

var dialogue_editor: Control

func _enter_tree():
	dialogue_editor = dialogue_editor_scene.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(dialogue_editor)
	# Hide the main panel.
	_make_visible(false)


func _exit_tree():
	if dialogue_editor:
		dialogue_editor.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible: bool):
	if dialogue_editor:
		dialogue_editor.visible = visible


func _get_plugin_name():
	return "DialogueManager"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("EditAddRemove", "EditorIcons")
