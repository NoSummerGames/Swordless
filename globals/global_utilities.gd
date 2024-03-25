extends Node

func add_timer(one_shot: bool, time: float) -> Timer:
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.one_shot = one_shot
	timer.wait_time = time
	timer.start()
	await timer.timeout
	timer.queue_free()
	return

func get_all_chidren(node: Node) -> Array[Node]:
	var nodes : Array[Node] = []
	var _get_all_children: Callable = func(_node: Node, lambda: Callable) -> void:
		for child: Node in _node.get_children():
			if child.get_child_count() > 0:
				nodes.append(child)
				lambda.call(child, lambda)
			else:
				nodes.append(node)
	if nodes.is_empty():
		_get_all_children.call(node, _get_all_children)
	return nodes

