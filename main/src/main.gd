extends CanvasLayer


@export var world_loader : WorldLoader
@export var menu_loader : MainMenuLoader


func _ready() -> void:
	world_loader.level_loading.connect(menu_loader._on_level_loading)
	world_loader.level_loaded.connect(menu_loader._on_level_loaded)
	menu_loader.play_pressed.connect(world_loader.launch_game)
