extends Node3D

@export var part: PackedScene
@export var part_scale: int = 1
@export var starting_distance: int = 100

func _ready() -> void:
	$Player.exited_path.connect($PartGenerator._on_player_exited_path)
	$Player.restarted.connect($PartGenerator._on_player_restarted)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		$Player.global_transform = Transform3D.IDENTITY
		$Player.emit_signal("restarted")

