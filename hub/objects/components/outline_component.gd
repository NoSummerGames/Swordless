class_name OutlineComponent
extends Component3D

@export var input_color: InputColorComponent
@export var _sprite: Sprite3D

static var outline_size: int = 2
static var alpha_treshold: float = 0.1

var sprite_outline: Sprite3D

var current_color: Color:
	get:
		return input_color.current_color

func _ready() -> void:
	sprite_outline = Sprite3D.new()
	sprite_outline.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	sprite_outline.render_priority = 1
	add_child(sprite_outline)

	if _sprite as Sprite3D != null:
		var tex: Texture2D = _sprite.texture.duplicate()
		_sprite.texture = grow_transparent_edges(tex)



func _process(_delta: float) -> void:
	sprite_outline.texture = get_outline(_sprite.texture)


func grow_transparent_edges(tex: Texture2D) -> Texture2D:
	var image: Image = tex.get_image()
	image.decompress()
	var image_copy: Image = image.duplicate()
	image_copy.resize(image.get_width() + outline_size * 2, image.get_height() + outline_size * 2)

	var image_size: Vector2i = image_copy.get_size()
	var original_size: Vector2i = image.get_size()

	for x: int in image_size.x:
		for y: int in image_size.y:
			if x < outline_size or y < outline_size:
				image_copy.set_pixel(x,y, Color.TRANSPARENT)
			elif x >= outline_size + original_size.x or y >= outline_size + original_size.y:
				image_copy.set_pixel(x,y, Color.TRANSPARENT)
			else:
				var pixel: Color = image.get_pixel(x - outline_size, y - outline_size)
				if pixel.a > alpha_treshold:
					image_copy.set_pixel(x,y, pixel)
				else:
					image_copy.set_pixel(x,y, Color.TRANSPARENT)
	image_copy.fix_alpha_edges()
	return ImageTexture.create_from_image(image_copy)


func get_outline(tex: Texture2D) -> Texture2D:
	var image: Image = tex.get_image()
	var bmp : BitMap = BitMap.new()
	var ext_bmp : BitMap = BitMap.new()

	image.decompress()

	bmp.create_from_image_alpha(image, alpha_treshold)
	ext_bmp = bmp.duplicate()

	# BUG : this method triggers an "out-of-bounds" error when set to a positive value
	ext_bmp.grow_mask(-outline_size, get_viewport().get_visible_rect())

	var size: Vector2i = ext_bmp.get_size()

	for x: int in size.x:
		for y: int in size.y:
			if bmp.get_bit(x, y) != ext_bmp.get_bit(x,y):
				image.set_pixel(x, y, current_color)
			else:
				image.set_pixel(x, y, Color(current_color, 0.0))
	return ImageTexture.create_from_image(image)
