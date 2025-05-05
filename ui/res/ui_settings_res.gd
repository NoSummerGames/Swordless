class_name UiSettings
extends Resource

@export_category("Dialogue Settings")
# General settings
@export var dialogue_background_blur: float = 0.01
# Portrait settings
@export var dialogue_portrait_animation_time: float = 0.5
@export var dialogue_portrait_transition: Tween.TransitionType = Tween.TransitionType.TRANS_EXPO
@export var dialogue_portrait_ease: Tween.EaseType = Tween.EaseType.EASE_IN
# Text settings
@export var character_delay: float = 0.1
