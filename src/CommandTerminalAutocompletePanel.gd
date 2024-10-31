class_name CommandTerminalAutocompletePanel
extends PanelContainer

@onready var command_terminal_guts : CommandTerminalGuts = self.get_parent().get_parent()
@onready var terminal_panel : CommandTerminalTerminalPanel = command_terminal_guts.terminal_panel
@onready var autocomplete_rich_label : RichTextLabel = $"%AUTOCOMPLETE-RICH-LABEL"

var existing_char_count : int = 0
func _ready() -> void:
	terminal_panel.contents_altered.connect(refresh_autocomplete_contents)
	self.hide()

func refresh_autocomplete_contents(new_text : String) -> void:
	CommandTerminalLogger.log(3, ["AUTOCOMPLETE"], "Getting autocomplete options for '%s'..." % [new_text])
	fetch_autocomplete_entries(new_text)
	CommandTerminalLogger.log(3, ["AUTOCOMPLETE"], "Fetched: %s" % [autocomplete_entries])
	autocomplete_selected_index = -1
	redraw_autocomplete_contents(new_text)

var autocomplete_entries : Array[String] = []
var autocomplete_entry_owners : Array[Argument] = []
func fetch_autocomplete_entries(new_text : String) -> void:
	var lextreeroot : CommandLexer.LexTreeNode = command_terminal_guts.tokenizer_cache(new_text)
	autocomplete_entries.clear()
	autocomplete_entry_owners.clear()
	_fetch_autocomplete_entries(lextreeroot)

func _fetch_autocomplete_entries(_token_tree_node : CommandLexer.LexTreeNode) -> void:
	if _token_tree_node == null: return
	if _token_tree_node.token is CommandLexer.CommandToken:
		for entry : String in _token_tree_node.token.provided_autocomplete_entries:
			autocomplete_entries.append(entry)
			autocomplete_entry_owners.append(_token_tree_node.token.argument)
	for child : CommandLexer.LexTreeNode in _token_tree_node.children:
		_fetch_autocomplete_entries(child)

var autocomplete_selected_index : int = 0
func advance_autocomplete_index() -> void: _change_autocomplete_index(true)
func reverse_autocomplete_index() -> void: _change_autocomplete_index(false)
func _change_autocomplete_index(forward : bool) -> void:
	if autocomplete_entries.is_empty(): return
	autocomplete_selected_index -= 1 if forward else -1
	autocomplete_selected_index = wrapi(autocomplete_selected_index, 0, len(autocomplete_entries))
	var selected_owner : Argument = autocomplete_entry_owners[autocomplete_selected_index]
	var autocomplete_text : String = autocomplete_entries[autocomplete_selected_index]
	CommandTerminalLogger.log(3, ["AUTOCOMPLETE"], "Selected entry: %s" % [autocomplete_text])
	if selected_owner is PeculiarArgument:
		autocomplete_text = selected_owner.get_autocomplete_content()
	CommandTerminalLogger.log(3, ["AUTOCOMPLETE"], "Autocompleteing: %s" % [autocomplete_text])
	terminal_panel.autocomplete_text(autocomplete_text)
	redraw_autocomplete_contents()

var previous_line_edit_contents : String = ""
func redraw_autocomplete_contents(line_edit_contents : String = previous_line_edit_contents) -> void:
	if autocomplete_entries.is_empty() or not terminal_panel.terminal_line_edit.has_focus() or terminal_panel.terminal_line_edit.text.is_empty():
		self.visible = false
		return
	else:
		self.visible = true

	autocomplete_rich_label.clear()
	for index : int in range(0, len(autocomplete_entries)):
		var content : String = autocomplete_entries[index]
		if index == autocomplete_selected_index:
			autocomplete_rich_label.push_color(Color.YELLOW)
			autocomplete_rich_label.append_text(content)
			autocomplete_rich_label.pop()
		else:
			autocomplete_rich_label.append_text(content)
		autocomplete_rich_label.append_text("\n")
	previous_line_edit_contents = line_edit_contents
	update_autocomplete_position_and_size(line_edit_contents)

@onready var command_line_font : Font = command_terminal_guts.parent_node.font
@onready var command_line_font_size : int = command_terminal_guts.parent_node.font_size
@onready var margin_container : MarginContainer = self.get_node("MarginContainer") 
@onready var margins : int = margin_container.get_theme_constant("margin_left") + margin_container.get_theme_constant("margin_right") 

func update_autocomplete_position_and_size(line_edit_contents : String) -> void:
	var complete_args : Array[String] = command_terminal_guts.get_all_complete_args(line_edit_contents)
	var string_to_pad : String = " ".join(complete_args + [""])
	CommandTerminalLogger.log(3, ["AUTOCOMPLETE"], "Placeing autocomplete panel relative to: '%s'" % [string_to_pad])
	var px_to_pad : float = command_line_font.get_string_size(
		string_to_pad,
		HORIZONTAL_ALIGNMENT_LEFT, 
		-1, 
		command_line_font_size
	).x
	
	var panel_size : Vector2 = command_line_font.get_multiline_string_size(
		autocomplete_rich_label.get_parsed_text(), 
		HORIZONTAL_ALIGNMENT_LEFT, 
		-1, 
		command_line_font_size
	) + Vector2(margins, margins)

	self.size = panel_size
	self.position = Vector2(
		px_to_pad,
		-panel_size.y
	)
