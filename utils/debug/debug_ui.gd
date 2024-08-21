extends CanvasLayer

const SAVE_PATH: String = "user://debug_preferences.cfg"

enum Levels {NONE, HUB, RUN}

signal debug_changed

@export var debug_menu: PackedScene
@export var player_stats: PlayerStatsResource

var player: Player
var body: MeshInstance3D
var action: Action

var settings : Dictionary = {
	Levels.RUN : {
		"speed": false,
		"altitude": false,
		"timer": false,
		"action_state": false,
		"freeze": false,
		"glide": false
	},
	Levels.HUB: {
		"null": true
	},
	Levels.NONE: {
		"null": true
	}
}

var stats: Dictionary = {}

var current_menu: Node

var current_level: Levels = Levels.NONE:
	set(value):
		await get_tree().process_frame
		if value != current_level and value == Levels.RUN:
			player.restarted.connect(set.bind("time", 0))

		current_level = value
		_load_settings()

var excluded_stats = ["dash_duration", "dash_sensitivity", "dash_acceleration", \
"input_buffer", "priority_buffer", "half_jump_buffer", "half_jump_deceleration"]

var previous_position: Vector3
var collision_raycast: RayCast3D
var time: float

@onready var action_label: Label = %ActionLabel
@onready var speed_label: Label = %SpeedLabel
@onready var altitude_label: Label = %AltitudeLabel
@onready var timer_label: Label = %TimerLabel

@onready var default_player_stats: PlayerStatsResource

@onready var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	default_player_stats = player_stats.duplicate()
	_load_settings()

func _unhandled_input(event: InputEvent) -> void:
	if current_level == Levels.RUN:
		if Input.is_action_just_pressed("debug"):
			if get_tree().paused == false:
				get_tree().paused = true
				current_menu = debug_menu.instantiate()
				add_child(current_menu)
			else:
				get_tree().paused = false
				if is_instance_valid(current_menu):
					current_menu.queue_free()

func _process(delta: float) -> void:
	match current_level:
		Levels.RUN:
			if get_setting("action_state") == true:
				if player.current_action !=  action:
					var action = player.current_action
					action_label.text = action.name
					body.mesh.material.albedo_color = action.debug_color
				action_label.position = get_viewport().get_camera_3d().unproject_position(player.global_position)

func _physics_process(delta: float) -> void:
	match current_level:
		Levels.RUN:
			if get_setting("speed") == true:
				var current_position = player.global_position
				var current_velocity = (current_position - previous_position)/delta
				var speed = Vector3.ZERO.distance_to(Vector3(current_velocity.x, 0, current_velocity.z))
				speed_label.text = "Speed : {}".format([snappedf(speed, 0.1)], "{}")
				previous_position = current_position

			if get_setting("altitude") == true:
				if collision_raycast:
					var collision_point = collision_raycast.get_collision_point()
					var altitude = player.global_position.distance_to(collision_point)
					altitude_label.text = "Altitude : {}".format([snappedf(altitude, 0.1)], "{}")

			if not get_tree().paused:
				time += delta
				%TimerLabel.text = "Timer : {}".format([snappedf(time, 0.1)], "{}")

func change_setting(setting: String, value: Variant):
	set_setting(setting, value)

	match current_level:
		Levels.RUN:
			match setting:
				"action_state":
					action_label.visible = value
					if value == true:
						body.mesh.material.albedo_color = player.current_action.debug_color
					else:
						body.mesh.material.albedo_color = Color.WHITE
				"speed":
					speed_label.visible = value
				"altitude":
					altitude_label.visible = value
					if value == true:
						collision_raycast = RayCast3D.new()
						collision_raycast.target_position = Vector3.DOWN * 100
						player.add_child(collision_raycast)
					else:
						if collision_raycast:
							collision_raycast.queue_free()

				"timer":
					timer_label.visible = value

				"freeze":
					for action: Action in player.actions:
						if action.name == "Freeze":
							action.disabled = !value
				"glide":
					for action: Action in player.actions:
						if action.name == "glide":
							action.disabled = !value

func change_stat(stat_name: String, value: Variant):
	stats[stat_name] = value
	player_stats.set(stat_name, value)

	if current_level == Levels.RUN:
		player.player_stats = player_stats

	_save_stat(stat_name, value)

func clear_stat(stat_name: String):
	for stat in stats.keys():
		if stat == stat_name:
			stats.erase(stat)
			player_stats.set(stat_name, default_player_stats.get(stat_name))
	config.erase_section_key("stats", stat_name)

	_save_settings()

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

	for setting in config.get_section_keys(str(current_level)):
		var config_value = config.get_value(str(current_level), setting, null)

		settings[current_level][setting] = config_value
		call_deferred("change_setting", setting, config_value)

	if "stats" in config.get_sections():
		for stat in config.get_section_keys("stats"):
			var config_value = config.get_value("stats", stat, 0)
			stats[stat] = config_value
			call_deferred("change_stat", stat, config_value)


func _save_settings():
	for category in settings:
		for setting in settings[category]:
			config.set_value(str(category), setting, settings[category][setting])

	for stat in stats:
		config.set_value("stats", stat, stats[stat])

	var error = config.save(SAVE_PATH)

	if error != OK:
		printerr("Settings couldn't be saved, error : {_}".format(error))

func _save_stat(stat_name: String, value: Variant):
	if stats.has(stat_name):
		config.set_value("stats", stat_name, value)
	var error = config.save(SAVE_PATH)

	if error != OK:
		printerr("Stat couldn't be saved, error : {_}".format(error))

func save_setting(setting: String, value: Variant):
	for category in settings:
		if settings[category].has(setting):
			config.set_value(str(category), setting, value)

	var error = config.save(SAVE_PATH)

	if error != OK:
		printerr("Settings couldn't be saved, error : {_}".format(error))
