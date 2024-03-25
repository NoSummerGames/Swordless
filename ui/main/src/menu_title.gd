extends GameMenu


func _on_play_button_up() -> void:
	master.trigger = "play"


func _on_settings_button_down() -> void:
	master.trigger = "settings"


func _on_quit_button_up() -> void:
	master.trigger = "quit"
