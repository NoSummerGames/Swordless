extends Label

func _ready() -> void:
	var project_version: String = ProjectSettings.get_setting("application/config/version")
	self.text = project_version
