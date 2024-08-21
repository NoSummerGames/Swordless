extends Control

signal exposure_changed

const SAVE_PATH: String = "user://config.cfg"

var settings : Dictionary = {
	"game" : {
		"language": Languages.FRENCH
	},
	"graphics" : {
		"fullscreen": true,
		"resolution": Resolutions.NATIVE,
		"exposure": 1
	},
	"audio" : {
		"music_volume": 1,
		"sound_volume": 1
	}
}

var previous_window_mode: int

enum Resolutions {
	HALF = 0,
	NATIVE = 1,
	DOUBLE = 2
}

enum Languages {
	FRENCH = 1
}

@onready var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	_load_settings()

func get_setting(setting: String):
	for category in settings:
		if settings[category].has(setting):
			return settings[category][setting]
	return "null"


func set_setting(setting: String, value: Variant):
	for category in settings:
		if settings[category].has(setting):
			settings[category][setting] = value

	save_setting(setting, value)

func _load_settings():
	var error = config.load(SAVE_PATH)

	if error != OK:
		config = ConfigFile.new()
		_save_settings()
		print("A new config file has been created in the user folder.")

	for category in config.get_sections():
		for setting in config.get_section_keys(category):
			var config_value = config.get_value(category, setting, null)

			#if settings[category][setting] != config_value:
			settings[category][setting] = config_value
			change_setting(setting, config_value)


func _save_settings():
	for category in settings:
		for setting in settings[category]:
			config.set_value(category, setting, settings[category][setting])

	var error = config.save(SAVE_PATH)

	if error != OK:
		printerr("Settings couldn't be saved, error : {_}".format(error))

func save_setting(setting: String, value: Variant):
	for category in settings:
		if settings[category].has(setting):
			config.set_value(category, setting, value)

	var error = config.save(SAVE_PATH)

	if error != OK:
		printerr("Settings couldn't be saved, error : {_}".format(error))

func change_setting(setting: String, value: Variant):
	match setting:
		# Game settings
		"language":
			pass

		# Graphic settings
		"fullscreen":
			if value == true:
				#previous_window_mode = DisplayServer.window_get_mode()
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		"resolution":
			match value:
				Resolutions.HALF:
					RenderingServer.viewport_set_scaling_3d_scale(get_viewport().get_viewport_rid(), 0.5)
				Resolutions.NATIVE:
					RenderingServer.viewport_set_scaling_3d_scale(get_viewport().get_viewport_rid(), 1)
				Resolutions.DOUBLE:
					RenderingServer.viewport_set_scaling_3d_scale(get_viewport().get_viewport_rid(), 2)

		"exposure":
			call_deferred("emit_signal", "exposure_changed")

		# Audio settings
		"music_volume":
			var volume_db = linear_to_db(value)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume_db)

		"sound_volume":
			var volume_db = linear_to_db(value)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), volume_db)

	set_setting(setting, value)
