@tool
class_name CommandTerminalPlugin
extends EditorPlugin

var data := CommandTerminalPluginData.new()

func _enable_plugin() -> void:
	add_autoload_singleton("CommandServer", "res://addons/command-terminal/src/CommandServer.gd")
	CommandTerminalLogger.log(0, ["PLUGIN"], "CommandTerminal plugin enabled.")
	
func _enter_tree() -> void:
	_handle_project_settings()

func _handle_project_settings() -> void:
	for project_setting_data : Dictionary in data.PROJECT_SETTINGS:
		var project_setting_path : StringName = project_setting_data["name"]
		if not ProjectSettings.has_setting(project_setting_path):
			#""Create"" the setting.
			ProjectSettings.set_setting(project_setting_path, project_setting_data["default"])
		_set_setting_metadata(project_setting_data)
		CommandTerminalLogger.log(1, ["PLUGIN"], "Registered plugin setting %s." % [project_setting_path])

func _disable_plugin() -> void:
	remove_autoload_singleton("CommandServer")
	for project_setting_data in data.PROJECT_SETTINGS:
		ProjectSettings.set_setting(project_setting_data["name"], null)
	CommandTerminalLogger.log(0, ["PLUGIN"], "CommandTerminal plugin disabled.")
		
func _set_setting_metadata(setting_data : Dictionary) -> void:
	_set_setting_property_info(setting_data)
	_set_setting_basic(setting_data)

func _set_setting_property_info(info: Dictionary) -> void:
	var culled_info : Dictionary = {
		"name" : info["name"],
		"type" : info["type"],
		"hint" : info["hint"],
		"hint_string" : info["hint_string"],
	}
	ProjectSettings.add_property_info(culled_info)

func _set_setting_basic(setting_data: Dictionary) -> void:
	var version_dict : Dictionary = Engine.get_version_info()
	if version_dict["major"] >= 4 and version_dict["minor"] >= 1:
		ProjectSettings.call("set_as_basic", setting_data["name"], setting_data["basic"])