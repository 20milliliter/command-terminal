@tool
class_name CommandTerminalPlugin
extends EditorPlugin

var _console_key: InputEventKey = preload("res://addons/command-terminal/ast/default_console_key.tres").duplicate()

const PLUGIN_ID := "command_terminal"
const PLUGIN_PATH := "plugins/" + PLUGIN_ID
const CONSOLE_KEY_SHORTCUT := PLUGIN_PATH + "/console_key_shortcut"

func _enable_plugin():
	add_autoload_singleton("CommandServer", "res://addons/command-terminal/src/CommandServer.gd")
	_set_setting_or_default(CONSOLE_KEY_SHORTCUT, _console_key)
	_set_setting_info({
		"name" : CONSOLE_KEY_SHORTCUT,
		"type" : TYPE_OBJECT,
	})
	_set_setting_basic(CONSOLE_KEY_SHORTCUT, true)
	print("[COMMAND TERMINAL][PLUGIN] CommandTerminal plugin enabled.")
	
func _disable_plugin():
	remove_autoload_singleton("CommandServer")
	_set_setting_or_default(CONSOLE_KEY_SHORTCUT, null)
	print("[COMMAND TERMINAL][PLUGIN] CommandTerminal plugin disabled.")
		
func _set_setting_or_default(setting_name: String, value: Variant) -> void:
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, value)
	ProjectSettings.set_initial_value(setting_name, value)

func _set_setting_info(info: Dictionary) -> void:
	ProjectSettings.add_property_info(info)

func _set_setting_basic(setting_name : String, basic : bool) -> void:
	ProjectSettings.set_as_basic(setting_name, basic)


