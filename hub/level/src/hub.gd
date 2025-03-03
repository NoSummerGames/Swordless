class_name Hub
extends Node3D

signal level_entered(level: PackedScene)

enum Chapter {NONE, ONE, TWO, THREE}

var characters: Array[Character]
var chapter: Chapter = Chapter.NONE

func _ready() -> void:
	# HACK
	_connect_passages()


# HACK
func _connect_passages() -> void:
	for child in Utilities.get_all_children(self):
		if child is Passage:
			var passage: Passage = child
			passage.interacted.connect(level_entered.emit.bind(passage.passage_resource.classic_level_scene))
