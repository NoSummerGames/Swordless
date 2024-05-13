extends Node

signal debug_changed
var debug: bool = false

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

func get_all_chidren(node: Node) -> Array[Node]:
	var nodes : Array[Node] = []
	var _get_all_children = func(_node: Node, lambda: Callable):
		for child in _node.get_children():
			if child.get_child_count() > 0:
				nodes.append(child)
				lambda.call(child, lambda)
			else:
				nodes.append(node)
	if nodes.is_empty():
		_get_all_children.call(node, _get_all_children)
	return nodes

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		debug = not debug
		emit_signal("debug_changed", debug)
