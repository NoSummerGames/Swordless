class_name LevelProgressBar
extends ProgressBar

const ANIM_TIME: float = 1.5

var level: Level

@onready var path: Path3D = level.level_generator
@onready var player: Player = level.player

func _init(current_level: Level) -> void:
	level = current_level

func _ready() -> void:
	# Theme setup
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)

	# Delete when level is restarted
	level.level_restarted.connect(queue_free)

	# Calculate player progression on the path
	var progression: float = (player.path_progression / path.curve.get_baked_length())
	var tween: Tween = get_tree().create_tween()

	# Tween progression display
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "value", progression * 100, ANIM_TIME)
