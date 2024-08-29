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

func get_setting(setting: String) -> Variant:
	for category: String in settings:
		var cat_dict: Dictionary = settings[category]
		if cat_dict.has(setting):
			return cat_dict[setting]
	return "null"


func set_setting(setting: String, setting_value: Variant) -> void:
	for category: String in settings:
		var cat_dict: Dictionary = settings[category]
		if cat_dict.has(setting):
			cat_dict[setting] = setting_value

	save_setting(setting, setting_value)

func _load_settings() -> void:
	var error: Error = config.load(SAVE_PATH)

	if error != OK:
		config = ConfigFile.new()
		_save_settings()
		print("A new config file has been created in the user folder.")

	for category: String in config.get_sections():
		for setting: String in config.get_section_keys(category):
			var config_value: Variant = config.get_value(category, setting, null)

			#if settings[category][setting] != config_value:
			settings[category][setting] = config_value
			change_setting(setting, config_value)


func _save_settings() -> void:
	for category: String in settings:
		for setting: String in settings[category]:
			config.set_value(category, setting, settings[category][setting])

	var error: Error = config.save(SAVE_PATH)

	if error != OK:
		printerr("Settings couldn't be saved, error : {_}".format(error))

func save_setting(setting: String, setting_value: Variant) -> void:
	for category: String in settings:
		var cat_dict: Dictionary = settings[category]
		if cat_dict.has(setting):
			config.set_value(category, setting, setting_value)

	var error: Error = config.save(SAVE_PATH)

	if error != OK:
		printerr("Settings couldn't be saved, error : {_}".format(error))

func change_setting(setting: String, setting_value: Variant) -> void:
	match setting:
		# Game settings
		"language":
			pass

		# Graphic settings
		"fullscreen":
			if setting_value == true:
				#previous_window_mode = DisplayServer.window_get_mode()
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		"resolution":
			match setting_value:
				Resolutions.HALF:
					RenderingServer.viewport_set_scaling_3d_scale(get_viewport().get_viewport_rid(), 0.5)
				Resolutions.NATIVE:
					RenderingServer.viewport_set_scaling_3d_scale(get_viewport().get_viewport_rid(), 1)
				Resolutions.DOUBLE:
					RenderingServer.viewport_set_scaling_3d_scale(get_viewport().get_viewport_rid(), 2)

		"exposure":
			await get_tree().process_frame
			exposure_changed.emit()

		# Audio settings
		"music_volume":
			var volume: float = setting_value
			_set_volume("Music", volume)

		"sound_volume":
			var volume: float = setting_value
			_set_volume("Sound", volume)

	set_setting(setting, setting_value)

func _set_volume(bus_index: String, value: float) -> void:
	var volume_db: float = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_index), volume_db)
