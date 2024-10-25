class_name CommandTerminalAutofillPanel
extends PanelContainer

@onready var command_terminal_guts : CommandTerminalGuts = self.get_parent().get_parent()
@onready var terminal_panel : CommandTerminalTerminalPanel = command_terminal_guts.terminal_panel
@onready var autofill_rich_label : RichTextLabel = $"%AUTOFILL-RICH-LABEL"

var existing_char_count : int = 0
func _ready() -> void:
	terminal_panel.contents_altered.connect(refresh_autofill_contents)
	self.hide()

func refresh_autofill_contents(new_text : String) -> void:
	CommandTerminalLogger.log(3, ["AUTOFILL"], "Getting autofill options for '%s'..." % [new_text])
	fetch_autofill_entries(new_text)
	CommandTerminalLogger.log(3, ["AUTOFILL"], "Fetched: %s" % [autofill_entries])
	autofill_selected_index = -1
	redraw_autofill_contents(new_text)

var autofill_entries : Array[String] = []
var autofill_entry_owners : Array[Argument] = []
func fetch_autofill_entries(new_text : String) -> void:
	var tokentreeroot : CommandTokenizer.TokenTreeNode = command_terminal_guts.tokenizer_cache(new_text)
	autofill_entries.clear()
	autofill_entry_owners.clear()
	_fetch_autofill_entries(tokentreeroot)

func _fetch_autofill_entries(_token_tree_node : CommandTokenizer.TokenTreeNode) -> void:
	if _token_tree_node == null: return
	if _token_tree_node.token is CommandTokenizer.CommandToken:
		for entry : String in _token_tree_node.token.provided_autofill_entries:
			autofill_entries.append(entry)
			autofill_entry_owners.append(_token_tree_node.token.argument)
	for child : CommandTokenizer.TokenTreeNode in _token_tree_node.children:
		_fetch_autofill_entries(child)

var autofill_selected_index : int = 0
func advance_autofill_index() -> void: _change_autofill_index(true)
func reverse_autofill_index() -> void: _change_autofill_index(false)
func _change_autofill_index(forward : bool) -> void:
	if autofill_entries.is_empty(): return
	autofill_selected_index -= 1 if forward else -1
	autofill_selected_index = wrapi(autofill_selected_index, 0, len(autofill_entries))
	var selected_owner : Argument = autofill_entry_owners[autofill_selected_index]
	var autofill_text : String = autofill_entries[autofill_selected_index]
	CommandTerminalLogger.log(3, ["AUTOFILL"], "Selected entry: %s" % [autofill_text])
	if selected_owner is PeculiarArgument:
		autofill_text = selected_owner.get_autofill_content()
	CommandTerminalLogger.log(3, ["AUTOFILL"], "Autofilling: %s" % [autofill_text])
	terminal_panel.autofill_text(autofill_text)
	redraw_autofill_contents()

var previous_line_edit_contents : String = ""
func redraw_autofill_contents(line_edit_contents : String = previous_line_edit_contents) -> void:
	if autofill_entries.is_empty() or not terminal_panel.terminal_line_edit.has_focus() or terminal_panel.terminal_line_edit.text.is_empty():
		self.visible = false
		return
	else:
		self.visible = true

	autofill_rich_label.clear()
	for index : int in range(0, len(autofill_entries)):
		var content : String = autofill_entries[index]
		if index == autofill_selected_index:
			autofill_rich_label.push_color(Color.YELLOW)
			autofill_rich_label.append_text(content)
			autofill_rich_label.pop()
		else:
			autofill_rich_label.append_text(content)
		autofill_rich_label.append_text("\n")
	previous_line_edit_contents = line_edit_contents
	update_autofill_position_and_size(line_edit_contents)

@onready var command_line_font : Font = command_terminal_guts.parent_node.font
@onready var command_line_font_size : int = command_terminal_guts.parent_node.font_size
@onready var margin_container : MarginContainer = self.get_node("MarginContainer") 
@onready var margins : int = margin_container.get_theme_constant("margin_left") + margin_container.get_theme_constant("margin_right") 

func update_autofill_position_and_size(line_edit_contents : String) -> void:
	var complete_args : Array[String] = command_terminal_guts.get_all_complete_args(line_edit_contents)
	var string_to_pad : String = " ".join(complete_args + [""])
	CommandTerminalLogger.log(3, ["AUTOFILL"], "Placeing autofill panel relative to: '%s'" % [string_to_pad])
	var px_to_pad : float = command_line_font.get_string_size(
		string_to_pad,
		HORIZONTAL_ALIGNMENT_LEFT, 
		-1, 
		command_line_font_size
	).x
	
	var panel_size : Vector2 = command_line_font.get_multiline_string_size(
		autofill_rich_label.get_parsed_text(), 
		HORIZONTAL_ALIGNMENT_LEFT, 
		-1, 
		command_line_font_size
	) + Vector2(margins, margins)

	self.size = panel_size
	self.position = Vector2(
		px_to_pad,
		-panel_size.y
	)
