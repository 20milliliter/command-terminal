class_name CommandTerminalGuts
extends Node

var parent_node : CommandTerminal :
	get:
		return self.get_parent()
		
var terminal_panel : CommandTerminalTerminalPanel :
	get:
		return self.get_node("%TERMINAL-PANEL")

var autofill_panel : CommandTerminalAutofillPanel :
	get:
		return self.get_node("%AUTOFILL-PANEL")

func _ready():
	var _console_key = ProjectSettings.get_setting("plugins/command_terminal/console_key_shortcut").duplicate()
	InputMap.add_action("ui_console")
	InputMap.action_add_event("ui_console", _console_key)
	CommandTerminalLogger.log(2, ["TERMINAL"], "Registered 'ui_console' to InputMap")

	terminal_panel.command_ran.connect(CommandServer.run_command)