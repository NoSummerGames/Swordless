class_name SealMagnet
extends Node

const SPEED: int = 25
const MIN_DISTANCE: float = 0.5

var seal: Seal

func _init(broken_seal: Seal) -> void:
	seal = broken_seal

func attract(target: Player, delta: float) -> bool:
	target.gravity = Vector3.ZERO

	var target_pos: Vector3 = target.body.position / 2 + target.global_position
	var seal_pos: Vector3 = seal.global_position
	var direction: Vector3 = seal_pos - target_pos
	var dist: float = direction.length()

	if direction.dot(target.global_basis.z) < 0.5:
		# Move the player towards the seal without the Z component to avoid backward movement and stuttering
		var motion_vector: Vector3 =  direction.normalized() * Vector3(1, 1, 0) * SPEED * dist * delta
		target.move_and_collide(motion_vector)
		return true

	else:
		return false
