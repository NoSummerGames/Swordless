extends Node

@export var UI: Node
@export var world_loader : WorldLoader


func _ready() -> void:
	UI.connect("game_launched", _on_game_launched)
	UI.connect("game_quitted", _on_game_quitted)
	world_loader.connect("level_loading", Callable(UI, "_on_level_loading"))

func _on_game_launched() -> void:
	world_loader.launch_game()

func _on_game_quitted() -> void:
	get_tree().quit()



