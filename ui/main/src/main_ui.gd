extends MasterMenu

signal game_launched
signal game_quitted

func _ready() -> void:
	var title: PackedScene = menus["Title"]
	display_menu(title)

	# Connect triggers sent by buttons signals
	trigger_set.connect(_on_trigger_set)


func _on_level_loading() -> void:
	close_menus()

func _on_trigger_set(_trigger: String) -> void:
	match _trigger:
		"play":
			emit_signal("game_launched")
		"settings":
			var settings: PackedScene = menus["Settings"]
			display_menu(settings)
		"settings_back":
			var title: PackedScene = menus["Title"]
			display_menu(title)
		"quit":
			emit_signal("game_quitted")
