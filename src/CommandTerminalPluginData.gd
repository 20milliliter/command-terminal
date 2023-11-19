class_name CommandTerminalPluginData

const PLUGIN_ID := "command_terminal"
const PLUGIN_PATH := "plugins/" + PLUGIN_ID

var PROJECT_SETTINGS : Array = [
	{
		"name" : PLUGIN_PATH + "/console_key_shortcut",
		"description" : "The InputEvent to be associated with the 'ui_console' input action.",
		"type" : TYPE_OBJECT,
		"default" : preload("res://addons/command-terminal/ast/default_console_key.tres").duplicate(),
	},
	{
		"name" : PLUGIN_PATH + "/logging_quantity",
		"description" : "The amount of logging CommandTerminal should provide.",
		"type" : TYPE_INT,
		"default" : 1,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "None,Minimal,Verbose,All",
	},
	{
		"name" : PLUGIN_PATH + "/logging_types",
		"description" : "The types of logging CommandTerminal should provide.",
		"type" : TYPE_INT,
		"default" : 127,
		"hint" : PROPERTY_HINT_FLAGS,
		"hint_string" : "Plugin,Terminal,Navigation",
	},
]