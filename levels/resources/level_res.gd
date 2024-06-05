@tool
class_name LevelResource
extends CustomResource

@export var entry_section: EntrySection
@export var sections: Array[Section]
@export var exit_section: ExitSection
@export var smoothing_factor: SmoothingLevel
@export var starting_distance: int = 5

enum SmoothingLevel {NONE, LOW, MEDIUM, HIGH}
