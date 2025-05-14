@tool
extends HBoxContainer

@export var data: GameData

@onready var character_button: OptionButton = %CharacterButton

func _ready() -> void:
	for character: CharacterResource in data.characters:
		character_button.add_item(character.name, character.id)

	character_button.item_selected.connect(_on_character_selected)

func _on_character_selected(id: int) -> void:
	var character: CharacterResource = data.get_character(id)
