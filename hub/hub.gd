class_name Hub
extends Node3D

signal level_entered
signal passage_entered

@export var hub_ui: HubUi

func _ready() -> void:
	hub_ui.panel.passage_interacted.connect(_on_passage_entered)
func _on_child_entered_tree(node: Node) -> void:
	if node is HubPassage:
		var passage: HubPassage = node
		passage.interacted.connect(hub_ui._on_passage_interacted)
		passage_entered.connect(_on_passage_entered.bind(passage))

func _on_passage_entered(level: PackedScene) -> void:
	level_entered.emit(level)
