extends Node

signal events_updated

static var unhandled_events: Array[DialogueEvent]


func launch_event(event: DialogueEvent) -> void:
	unhandled_events.append(event)
	events_updated.emit()

func consume_event(event: DialogueEvent) -> void:
	unhandled_events.erase(event)
	events_updated.emit()


class DialogueEvent extends Resource:
	func _init() -> void:
		pass

	func consume(events: Array[DialogueEvent]) -> void:
		_consume()

	func _consume() -> void:
		pass

# Murder event
class EventMurder extends DialogueEvent:
	pass

# New character event
class EventNewCharacter extends DialogueEvent:
	var _character: Character

	func _init(character: Character) -> void:
		_character = character

	func _consume() -> void:
		_character.new = false

# Level finished event
class EventLevelFinished extends DialogueEvent:
	var _level: LevelResource

	func _init(level: LevelResource) -> void:
		_level = level

# Level failed event
class EventLevelFailed extends DialogueEvent:
	var _level: LevelResource

	func _init(level: LevelResource) -> void:
		_level = level

# Relic given event
class EventRelicGiven extends DialogueEvent:
	var _relic: RelicResource
	var _character: Character

	func _init(relic: RelicResource, character: Character) -> void:
		_relic = relic
		_character = character
