@tool
extends Node

var temp: Array = []

func add_timer(one_shot: bool, time: float) -> Timer:
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.one_shot = one_shot
	timer.wait_time = time
	timer.start()
	timer.timeout.connect(_remove_timer.bind(timer))
	return timer

func _remove_timer(timer: Timer) -> void:
	if is_instance_valid(timer):
		timer.queue_free()


func get_all_children(parent: Node) -> Array :
	temp.push_back(parent)
	for child: Node in parent.get_children():
		temp = get_all_children(child)

	var results: Array = temp.duplicate()
	temp.clear()
	return results

func test_collision(rid: RID, motion_transform: Transform3D, motion_velocity: Vector3) -> PhysicsTestMotionResult3D:
	var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
	parameters.from = motion_transform
	parameters.motion = motion_velocity
	var result : PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
	PhysicsServer3D.body_test_motion(rid, parameters, result)
	return result
