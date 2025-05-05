class_name DialogScreen
extends Control

signal pressed
signal exhausted

@export var settings: UiSettings

# Portrait variables
var origin: Vector2 = Vector2.LEFT
var texture: Texture2D

# Dialogue variables
var dialogues: Array[String] = []

@onready var portrait: TextureRect = %Portrait
@onready var dialogue_label: DialogueLabel = %DialogueLabel


func _ready() -> void:
	_animate_character_in()
	_display_dialogue()
	pressed.connect(_on_dialogue_pressed)
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hub_activate"):
		pressed.emit()


func _on_dialogue_pressed() -> void:
	# End text animation if any
	if dialogue_label.running:
		dialogue_label.stop()
	# Else display the next dialogue
	else:
		_display_dialogue()


func _display_dialogue() -> void:
	if not dialogues.is_empty():
		var current_text: String = dialogues.pop_front()
		dialogue_label.display_dialogue(current_text, origin, settings)
	else:
		exhausted.emit()
		queue_free()


func _animate_character_in() -> void:
	# Blur the background
	var blurry_viewport: TextureRect = %BlurryViewport
	blurry_viewport.texture = Utilities.get_blurred_viewport(get_viewport(), settings.dialogue_background_blur)

	# Set the character portrait texture
	portrait.texture = texture

	var x_pos: int = 0.0

	# Set expand and stretch so that the texture fits the screen size while keeping its aspect ratio
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT

	match origin:
		Vector2.LEFT:
			portrait.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
			# Set the texture position outside of the screen
			portrait.position.x -= portrait.size.x

		Vector2.RIGHT:
			portrait.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
			# Set the texture position outside of the screen
			portrait.position.x = get_viewport_rect().size.x + portrait.size.x
			x_pos = get_viewport_rect().size.x - portrait.size.x

	var final_position: Vector2 = Vector2(x_pos, portrait.position.y)

	# Tween the texture position to its final position
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(settings.dialogue_portrait_transition)
	tween.set_ease(settings.dialogue_portrait_ease)
	tween.tween_property(portrait, "position", final_position, settings.dialogue_portrait_animation_time)
