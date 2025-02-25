@icon("res://addons/command-terminal/ast/CommandTerminal.svg")
class_name CommandTerminal
extends PanelContainer

#@onready var autocomplete_panel : CommandTerminalAutocompletePanel = command_terminal_guts.autocomplete_panel

@onready var terminal_line_edit : CommandTerminalLineEdit = $"%TERMINAL-LINE-EDIT"

signal contents_altered(new_contents : String)
signal command_ran(command : String)
var last_ran_command : String = ""

func _ready() -> void:
	terminal_line_edit.terminal = self
	terminal_line_edit.terminal_rich_label.terminal = self

	var _console_key : Resource = ProjectSettings.get_setting("plugins/command_terminal/console_key_shortcut").duplicate()
	InputMap.add_action("ui_console")
	InputMap.action_add_event("ui_console", _console_key)
	CommandTerminalLogger.log(2, ["TERMINAL"], "Registered 'ui_console' to InputMap")

	terminal_line_edit.text_changed.connect(
		func(t : String) -> void: 
			fetch_autocomplete_entries(t)
			autocomplete_selected_index = 0
			terminal_line_edit.pre_autocompleted_text = t
			terminal_line_edit.terminal_rich_label.update_text(t)
			contents_altered.emit(t)
	)
	terminal_line_edit.text_submitted.connect(
		func(t : String) -> void: 
			terminal_line_edit.text = ""
			#terminal_rich_label.text = ""
			CommandTerminalLogger.log(2, ["TERMINAL"], "Terminal submitted with: '%s'." % [t]) 
			last_ran_command = t
			command_ran.emit(t)
			terminal_line_edit.text_changed.emit("")
	)
	#terminal_line_edit.focus_entered.connect(autocomplete_panel.redraw_autocomplete_contents)
	#terminal_line_edit.focus_exited.connect(autocomplete_panel.redraw_autocomplete_contents)

	#terminal_line_edit.clear()
	#terminal_rich_label.clear()

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

var autocomplete_entries : Array[String] = []
var autocomplete_entry_owners : Array[Argument] = []
func fetch_autocomplete_entries(new_text : String) -> void:
	CommandTerminalLogger.log(3, ["TERMINAL", "AUTOCOMPLETE"], "Fetching autocomplete entries for text: %s" % [new_text])
	var lextreeroot : CommandLexer.LexTreeNode = self.tokenizer_cache(new_text)
	autocomplete_entries.clear()
	autocomplete_entry_owners.clear()
	_fetch_autocomplete_entries(lextreeroot)

func _fetch_autocomplete_entries(_token_tree_node : CommandLexer.LexTreeNode) -> void:
	if _token_tree_node == null: return
	if _token_tree_node.token is CommandLexer.CommandToken:
		for entry : String in _token_tree_node.token.provided_autocomplete_entries:
			autocomplete_entries.append(entry)
			autocomplete_entry_owners.append(_token_tree_node.token.argument)
	var children : Array[CommandLexer.LexTreeNode] = _token_tree_node.children.duplicate()
	children.sort_custom(CommandServer._sort_pnaltn)
	for child : CommandLexer.LexTreeNode in children:
		_fetch_autocomplete_entries(child)

var autocomplete_selected_index : int = 0
func advance_autocomplete_index() -> void: _change_autocomplete_index(true)
func reverse_autocomplete_index() -> void: _change_autocomplete_index(false)
func _change_autocomplete_index(forward : bool) -> void:
	if autocomplete_entries.is_empty(): return
	if not terminal_line_edit.text == terminal_line_edit.pre_autocompleted_text:
		autocomplete_selected_index -= 1 if forward else -1
	autocomplete_selected_index = wrapi(autocomplete_selected_index, 0, len(autocomplete_entries))
	var selected_owner : Argument = autocomplete_entry_owners[autocomplete_selected_index]
	var autocomp_text : String = autocomplete_entries[autocomplete_selected_index]
	CommandTerminalLogger.log(3, ["AUTOCOMPLETE"], "Selected entry: %s" % [autocomp_text])
	if selected_owner is PeculiarArgument:
		autocomp_text = selected_owner.get_autocomplete_content()
	CommandTerminalLogger.log(3, ["AUTOCOMPLETE"], "Autocompleting: %s" % [autocomp_text])
	terminal_line_edit.autocomplete_text(autocomp_text)

func _get_all_complete_args(text : String) -> Array[String]:
	CommandTerminalLogger.log(3, ["TERMINAL"], "Complete args requested for: %s" % [text])
	var working_token_node : CommandLexer.LexTreeNode = self.tokenizer_cache(text)
	var args : Array[String] = []
	while working_token_node.children.size() > 0:
		working_token_node = working_token_node.children[0]
		if not working_token_node.token is CommandLexer.CommandToken: continue
		if working_token_node.token.content.is_empty(): continue
		if not working_token_node.token.provided_autocomplete_entries.is_empty(): break
		args.push_back(working_token_node.token.content)
	CommandTerminalLogger.log(3, ["TERMINAL"], "Returning: %s" % [args])
	return args

func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("ui_console"):
		var window_owner : Window = get_tree().get_root()
		var do_grab_focus_crosswindow : bool = ProjectSettings.get_setting(CommandTerminalPluginData.PLUGIN_PATH + "shortcut_works_cross-window")
		if do_grab_focus_crosswindow:
			window_owner.grab_focus()
		terminal_line_edit.grab_focus()