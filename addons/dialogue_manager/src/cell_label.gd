@tool
class_name CellLabel
extends RichTextLabel

signal selected
signal deleted

var dialogue_state: Character.Status = Character.Status.NEUTRAL
@export var close_button: Button

func _ready() -> void:
	focus_entered.connect(close_button.show)
	close_button.pressed.connect(deleted.emit.bind(self))
	#focus_exited.connect(close_button.hide)
	#close_button.gui_input.connect(_on_button_gui_input)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			selected.emit(self)



#func _on_button_gui_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#var mouse_event: InputEventMouseButton = event
		#if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			#deleted.emit(self)
