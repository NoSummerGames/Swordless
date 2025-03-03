class_name Dialogue
extends Resource

signal fullfilled

@export_multiline var text: String
@export_group("Conditions")
@export var status: Character.Status = Character.Status.NEUTRAL
@export var chapter: Hub.Chapter = Hub.Chapter.NONE
@export var one_shot: bool = true
