extends CanvasLayer

@export var debug_texture: Texture2D # DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG

@export var dialogue_scene: PackedScene

static var dialogue_popup: DialogScreen

var debug_origin: Vector2 = Vector2.RIGHT # DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG

func display_dialogue() -> void:
	assert(dialogue_scene)
	dialogue_popup = dialogue_scene.instantiate()

	dialogue_popup.origin = debug_origin # DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
	dialogue_popup.texture = debug_texture # DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
	dialogue_popup.dialogues.append_array(["Salut ! Comment ça va mon pote ?", "Ajouter une indication pour savoir si on progresse (si on est proche de la fin)"]) # DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG

	add_child(dialogue_popup)
