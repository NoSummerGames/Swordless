class_name DialogueLabel
extends Label

var running: bool = false

func _ready() -> void:
	text = ""

func display_dialogue(dialogue: String, origin: Vector2, settings: UiSettings) -> void:
	running = true

	# Display the text in the box on the opposite of the character side
	match origin:
		Vector2.LEFT:
			reparent(%RightBox)
		Vector2.RIGHT:
			reparent(%LeftBox)

	var text_timer: Timer = Timer.new()
	text_timer.one_shot = true
	add_child(text_timer)

	var length: int = dialogue.length()

	for i in length:
		if running == true:
			if i < length:
				if dialogue[i] == " ":
					continue
				else:
					text = dialogue.left(i)
					text_timer.start(settings.character_delay)
					await text_timer.timeout
		else:
			break

	text = dialogue
	stop()

func stop() -> void:
	running = false
