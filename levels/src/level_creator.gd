@tool
class_name LevelCreator
extends Node

signal level_created

var meshes: Array[MeshInstance3D]

@onready var part_loader: PartLoader = %PartLoader
@onready var section_loader: SectionLoader = %SectionLoader

func create_level(level: LevelResource, path: Path3D) -> void:
	path.curve = _create_curve()

	# Load EntryScene
	if is_instance_valid(level.entry_scene):
		var entry_part: Part = level.entry_scene.instantiate()
		part_loader.load_part(entry_part, path)

	# Load sections
	for section: Section in level.sections:
		section_loader.load_section(section, part_loader, path)

	# Load ExitScene
	if is_instance_valid(level.exit_scene):
		var exit_part: Part = level.exit_scene.instantiate()
		part_loader.load_part(exit_part, path)

	emit_signal("level_created")

func _create_curve() -> Curve3D:
	var curve: Curve3D = Curve3D.new()
	curve.add_point(Vector3.BACK)
	curve.add_point(Vector3.ZERO)

	var _delete_first_point: Callable = func() -> void : curve.remove_point(0)
	level_created.connect(_delete_first_point)

	return curve
