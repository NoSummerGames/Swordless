class_name GameData
extends Resource

@export var characters: Array[CharacterResource] = []
@export var levels: Array[LevelResource] = []

func get_character(id: int) -> CharacterResource:
	var character: CharacterResource
	for chr in characters:
		if chr.id == id:
			character = chr

	if character:
		return character
	else:
		printerr("Character {} couldn't be found. Returning null.".format([id], "{}"))
		return null
