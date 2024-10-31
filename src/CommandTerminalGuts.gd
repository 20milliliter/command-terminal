class_name CommandTerminalGuts
extends Node

var parent_node : CommandTerminal :
	get:
		return self.get_parent()
		
var terminal_panel : CommandTerminalTerminalPanel :
	get:
		return self.get_node("%TERMINAL-PANEL")

var autocomplete_panel : CommandTerminalAutocompletePanel :
	get:
		return self.get_node("%AUTOCOMPLETE-PANEL")

func _ready() -> void:
	var _console_key : Resource = ProjectSettings.get_setting("plugins/command_terminal/console_key_shortcut").duplicate()
	InputMap.add_action("ui_console")
	InputMap.action_add_event("ui_console", _console_key)
	CommandTerminalLogger.log(2, ["TERMINAL"], "Registered 'ui_console' to InputMap")

	terminal_panel.command_ran.connect(CommandServer.run_command)

var last_input : String = ""
var last_output : CommandLexer.LexTreeNode
func tokenizer_cache(new_text : String) -> CommandLexer.LexTreeNode:
	if new_text == last_input:
		CommandTerminalLogger.log(3, ["TERMINAL", "TOKENIZE"], "Tokenization cache hit")
		CommandTerminalLogger.log(3, ["TERMINAL", "TOKENIZE"], "Returning: \n%s" % [CommandLexer._print_tree(last_output)])
		return last_output
	else:
		CommandTerminalLogger.log(3, ["TERMINAL", "TOKENIZE"], "Tokenization required for: %s" % [new_text])
		last_input = new_text
		last_output = CommandLexer.tokenize_input(new_text)
		return last_output

func get_all_complete_args(text : String) -> Array[String]:
	CommandTerminalLogger.log(3, ["TERMINAL"], "Complete args requested for: %s" % [text])
	var working_token_node : CommandLexer.LexTreeNode = self.tokenizer_cache(text)
	var args : Array[String] = []
	while working_token_node.children.size() > 0:
		working_token_node = working_token_node.children[0]
		if not working_token_node.token is CommandLexer.CommandToken: continue
		if not working_token_node.token.provided_autocomplete_entries.is_empty(): break
		args.push_back(working_token_node.token.content)
	CommandTerminalLogger.log(3, ["TERMINAL"], "Returning: %s" % [args])
	return args
