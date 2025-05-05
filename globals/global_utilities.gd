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

static func get_blurred_viewport(viewport: Viewport, blur_scale: float = 0.01, resize_scale: float = 5.0) -> ImageTexture:
	var viewport_image: Image = viewport.get_texture().get_image()
	var original_img_size: Vector2i = viewport_image.get_size()
	var img_size: Vector2i = original_img_size * blur_scale
	viewport_image.resize(img_size.x, img_size.y, Image.INTERPOLATE_LANCZOS)
	img_size *= resize_scale
	viewport_image.resize(img_size.x, img_size.y, Image.INTERPOLATE_CUBIC)

	var texture: ImageTexture = ImageTexture.create_from_image(viewport_image)
	return texture
