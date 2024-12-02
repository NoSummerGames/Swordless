class_name Debug
extends CanvasLayer

const SAVE_PATH: String = "user://debug_preferences.cfg"

enum Levels {NONE, HUB, RUN}

@export var debug_menu: PackedScene
@export var player_stats: PlayerStatsResource

var player: Player
var body: MeshInstance3D
var past_action: Action

var settings : Dictionary = {
	Levels.RUN : {
		"speed": false,
		"altitude": false,
		"timer": false,
		"action_state": false,
		"double_jump": false,
		"dash_strafe": false,
		"wall_jump": false,
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
			time = 0

		current_level = value
		_load_settings()

var excluded_stats: Array[String] = ["dash_duration", "dash_sensitivity", "dash_acceleration", \
 "priority_buffer", "half_jump_buffer", "half_jump_deceleration"]

var previous_position: Vector3
var collision_raycast: RayCast3D
var time: float

var highest_altitude: float = 0

@onready var action_label: Label = %ActionLabel
@onready var speed_label: Label = %SpeedLabel
@onready var altitude_label: Label = %AltitudeLabel
@onready var timer_label: Label = %TimerLabel

@onready var default_player_stats: PlayerStatsResource

@onready var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	default_player_stats = player_stats.duplicate()
	_load_settings()

func _unhandled_input(_event: InputEvent) -> void:
	if current_level == Levels.RUN:
		if Input.is_action_just_pressed("debug"):
			if current_menu == null:
				get_tree().paused = true
				current_menu = debug_menu.instantiate()
				add_child(current_menu)
			else:
				get_tree().paused = false
				if is_instance_valid(current_menu):
					current_menu.queue_free()

func _process(_delta: float) -> void:
	match current_level:
		Levels.RUN:
			if get_setting("action_state") == true:
				if player.current_action !=  past_action:
					var current_action: Action = player.current_action
					action_label.text = current_action.name
					var material: Material = body.get_active_material(0)
					if material is StandardMaterial3D:
						(material as StandardMaterial3D).albedo_color = current_action.debug_color
					past_action = current_action
				action_label.position = get_viewport().get_camera_3d().unproject_position(player.global_position)

func _physics_process(delta: float) -> void:
	match current_level:
		Levels.RUN:
			if get_setting("speed") == true and not get_tree().paused:
				var current_position: Vector3 = player.global_position
				var current_desired_velocity: Vector3 = (current_position - previous_position)/delta
				var speed: float = Vector3.ZERO.distance_to(Vector3(current_desired_velocity.x, 0, current_desired_velocity.z))
				speed_label.text = "Speed : {}".format([snappedf(speed, 0.1)], "{}")
				previous_position = current_position

			if get_setting("altitude") == true:
				if is_instance_valid(collision_raycast):
					if collision_raycast.is_colliding():
						var collision_point: Vector3 = collision_raycast.get_collision_point()
						var altitude: float = player.global_position.distance_to(collision_point)
						altitude_label.text = "Altitude : {}".format([snappedf(altitude, 0.1)], "{}")
						if snappedf(altitude, 0.1) > highest_altitude :
							highest_altitude = snappedf(altitude, 0.1)
					else:
						altitude_label.text = "Altitude : 0"



			if not get_tree().paused:
				time += delta
				timer_label.text = "Timer : {}".format([snappedf(time, 0.1)], "{}")

func change_setting(setting: String, setting_value: Variant) -> void:
	set_setting(setting, setting_value)

	match current_level:
		Levels.RUN:
			match setting:
				# HUD
				"action_state":
					action_label.visible = setting_value
					if setting_value == true:
						var material: Material = body.get_active_material(0)
						if material is StandardMaterial3D:
							(material as StandardMaterial3D).albedo_color = player.current_action.debug_color
					else:
						var material: Material = body.get_active_material(0)
						if material is StandardMaterial3D:
							(material as StandardMaterial3D).albedo_color = Color.WHITE
				"speed":
					speed_label.visible = setting_value
				"altitude":
					altitude_label.visible = setting_value
					if setting_value == true:
						collision_raycast = RayCast3D.new()
						collision_raycast.target_position = Vector3.DOWN * 100
						player.add_child(collision_raycast)
					else:
						if collision_raycast:
							collision_raycast.queue_free()
				"timer":
					timer_label.visible = setting_value

				# SKILLS
				"double_jump":
					for action: Action in player.actions:
						if action.name == "DoubleJump":
							action.disabled = !setting_value
				"dash_strafe":
					for action: Action in player.actions:
						if action.name == "Dash" or action.name == "Strafe":
							action.disabled = !setting_value
				"wall_jump":
					for action: Action in player.actions:
						if action.name == "WallJump":
							action.disabled = !setting_value

				# GAMEPLAY
				"freeze":
					player.freeze_component.disabled = !setting_value

				"glide":
					for action: Action in player.actions:
						if action.name == "Glide":
							action.disabled = !setting_value

func change_stat(stat_name: String, stat_value: Variant) -> void:
	stats[stat_name] = stat_value
	player_stats.set(stat_name, stat_value)

	if current_level == Levels.RUN:
		player.player_stats = player_stats

	_save_stat(stat_name, stat_value)

func clear_stat(stat_name: String) -> void:
	for stat: String in stats.keys():
		if stat == stat_name:
			stats.erase(stat)
			player_stats.set(stat_name, default_player_stats.get(stat_name))
	config.erase_section_key("stats", stat_name)

	_save_settings()

func get_setting(setting: String) -> Variant:
	for category: int in settings:
		var cat_dict: Dictionary = settings[category]
		if cat_dict.has(setting):
			return settings[category][setting]
	return null

func set_setting(setting: String, setting_value: Variant) -> void:
	for category: int in settings:
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

	for setting: String in config.get_section_keys(str(current_level)):
		var config_value: Variant = config.get_value(str(current_level), setting, null)

		settings[current_level][setting] = config_value
		call_deferred("change_setting", setting, config_value)

	if "stats" in config.get_sections():
		for stat: String in config.get_section_keys("stats"):
			var config_value: Variant = config.get_value("stats", stat, 0)
			stats[stat] = config_value
			call_deferred("change_stat", stat, config_value)


func _save_settings() -> void:
	for category: int in settings:
		for setting: String in settings[category]:
			config.set_value(str(category), setting, settings[category][setting])

	for stat: String in stats:
		config.set_value("stats", stat, stats[stat])

	var error: Error = config.save(SAVE_PATH)

	if error != OK:
		printerr("Settings couldn't be saved, error : {_}".format(error))

func _save_stat(stat_name: String, stat_value: Variant) -> void:
	if stats.has(stat_name):
		config.set_value("stats", stat_name, stat_value)
	var error: Error = config.save(SAVE_PATH)

	if error != OK:
		printerr("Stat couldn't be saved, error : {_}".format(error))

func save_setting(setting: String, setting_value: Variant) -> void:
	for category: int in settings:
		var cat_dict: Dictionary = settings[category]
		if cat_dict.has(setting):
			config.set_value(str(category), setting, setting_value)

	var error: Error = config.save(SAVE_PATH)

	if error != OK:
		printerr("Settings couldn't be saved, error : {_}".format(error))
