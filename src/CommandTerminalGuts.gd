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

var last_input : String = ""
var last_output : CommandTokenizer.TokenTreeNode
func tokenizer_cache(new_text : String) -> CommandTokenizer.TokenTreeNode:
	if new_text == last_input:
		return last_output
	else:
		last_input = new_text
		last_output = CommandTokenizer.tokenize_input(new_text)
		return last_output