@tool
class_name Level
extends Node3D

signal level_finished
signal level_failed
signal level_restarted
signal level_exited

@export var level_resource: LevelResource

@export_tool_button("Regenerate level", "Path3D") var regen: Callable = _regenerate_level

var standalone: bool = true

@onready var level_generator: LevelGenerator = %LevelGenerator
@onready var player: Player = %Player
@onready var menu: MenuLoader = %LevelMenuLoader

func _ready() -> void:
	if not Engine.is_editor_hint():
		DebugUi.current_level = DebugUi.Levels.RUN

		player.reached_exit.connect(menu._on_player_reached_exit)
		player.reached_exit.connect(level_finished.emit)
		player.reached_exit.connect(player.set_block_signals.bind(true))

		player.died.connect(menu._on_player_died)
		player.died.connect(level_failed.emit)
		player.died.connect(player.set_block_signals.bind(true))

		menu.level = self
		menu.restart_pressed.connect(player.set_block_signals.bind(false))
		if standalone:
			var tree: SceneTree = get_tree()
			menu.restart_pressed.connect(tree.reload_current_scene)
		else:
			menu.restart_pressed.connect(level_restarted.emit)

		menu.exit_pressed.connect(player.set_block_signals.bind(false))

		if standalone:
			var tree: SceneTree = get_tree()
			menu.exit_pressed.connect(tree.quit)
		else:
			menu.exit_pressed.connect(level_exited.emit)

		menu.restart_pressed.connect(func(): DebugUi.run_count += 1)

func _regenerate_level() -> void:
	level_generator.regenerate_level()

func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		DebugUi.current_level = DebugUi.Levels.NONE
