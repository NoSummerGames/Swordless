@tool
extends Node

const BOOM_TIME: float = 0.25
const VEL_FACTOR: float = 0.5

const SPEED: float = 60

@export var seal: Seal
@export var meshes: Node3D
@export var seal_unbroke_material: Material
@export var seal_broke_material: Material
@export var debug_anim_player: AnimationPlayer

func _ready() -> void:
	for mesh: MeshInstance3D in meshes.get_children():
		for i: int in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(i, seal_unbroke_material)

		if randi_range(0, 1) > 0.6:
			mesh.queue_free()
			continue

		mesh.position += mesh.position * randf_range(0, 0.2)

	if not Engine.is_editor_hint():
		seal.broke.connect(_on_seal_broke)

func _on_seal_broke(velocity: Vector3) -> void:
	debug_anim_player.play("break")

	for mesh: MeshInstance3D in meshes.get_children():
		for i: int in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(i, seal_broke_material)

		if randi_range(0, 1) > 0.3:
			mesh.queue_free()
			continue

		var tween: Tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_CIRC)
		tween.finished.connect(mesh.queue_free)
		tween.tween_property(mesh, "position", (mesh.position.normalized() * randf_range(0.0, 1.0) + velocity.normalized() * VEL_FACTOR) * SPEED, BOOM_TIME)
