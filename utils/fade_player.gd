extends AnimationPlayer

signal finished

@export var master: WorldLoader
@export var fade_in_signal: String
@export var fade_out_signal: String
@export var color_rect: ColorRect

func _ready() -> void:
	master.fade_player = self
	master.connect(fade_in_signal, _on_fade_in_signal)
	master.connect(fade_out_signal, _on_fade_out_signal)

func _on_fade_in_signal() -> void:
	color_rect.show()
	play("fade_in")
	emit_signal("finished")

func _on_fade_out_signal() -> void:
	play("fade_out")
	await animation_finished
	color_rect.hide()
