@tool
class_name CommandTerminalPlugin
extends EditorPlugin

var data = CommandTerminalPluginData.new()

func _enable_plugin():
	add_autoload_singleton("CommandServer", "res://addons/command-terminal/src/CommandServer.gd")
	_handle_project_settings()
	CommandTerminalLogger.log(0, ["PLUGIN"], "CommandTerminal plugin enabled.")
	if not ProjectSettings.has_setting("plugins/command_terminal/console_key_shortcut"):
		push_error("Somehow, the CommandTerminal plugin failed to initialize correctly. Please disable and reenable it.")

func _handle_project_settings():
	for project_setting_data in data.PROJECT_SETTINGS:
		var project_setting = project_setting_data["name"]
		_set_setting_or_default(project_setting, project_setting_data["default"])
		_set_setting_info(project_setting_data)
		_set_setting_basic(project_setting, true)
		CommandTerminalLogger.log(2, ["PLUGIN"], "Registered plugin setting %s." % [project_setting])

func _disable_plugin():
	remove_autoload_singleton("CommandServer")
	for project_setting_data in data.PROJECT_SETTINGS:
		_set_setting_or_default(project_setting_data["name"], null)
	CommandTerminalLogger.log(0, ["PLUGIN"], "CommandTerminal plugin disabled.")
		
func _set_setting_or_default(setting_name: String, value: Variant) -> void:
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, value)
	ProjectSettings.set_initial_value(setting_name, value)

func _set_setting_info(info: Dictionary) -> void:
	ProjectSettings.add_property_info(info)

func _set_setting_basic(setting_name : String, basic : bool) -> void:
	var version = Engine.get_version_info()
	if version["major"] >= 4 and version["minor"] >= 1:
		ProjectSettings.call("set_as_basic", setting_name, basic)