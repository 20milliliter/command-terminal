class_name CommandTerminalAutofillPanel
extends PanelContainer

@onready var command_terminal_guts : CommandTerminalGuts = self.get_parent().get_parent()
@onready var terminal_panel : CommandTerminalTerminalPanel = command_terminal_guts.terminal_panel
@onready var autofill_rich_label : RichTextLabel = $"%AUTOFILL-RICH-LABEL"

var existing_char_count : int = 0
func _ready():
	terminal_panel.contents_altered.connect(refresh_autofill_contents)

func refresh_autofill_contents(new_text : String):
	fetch_autofill_entries(new_text)
	autofill_selected_index = -1
	redraw_autofill_contents(new_text)

var autofill_entries : Array[String] = []

func fetch_autofill_entries(new_text):
	var tokentreeroot : CommandTokenizer.TokenTreeNode = command_terminal_guts.tokenizer_cache(new_text)
	_fetch_autofill_entries(tokentreeroot)

func _fetch_autofill_entries(_token_tree_node):	
	if not _token_tree_node.token is CommandTokenizer.CommandToken: return
	autofill_entries.append_array(_token_tree_node.token.provided_autofill_entries)
	for child in _token_tree_node.children:
		_fetch_autofill_entries(child)

var autofill_selected_index = 0
func advance_autofill_index(): _change_autofill_index(true)
func reverse_autofill_index(): _change_autofill_index(false)
func _change_autofill_index(forward : bool):
	if autofill_entries.is_empty(): return
	autofill_selected_index -= 1 if forward else -1
	autofill_selected_index = wrapi(autofill_selected_index, 0, len(autofill_entries))
	var autofill_text = autofill_entries[autofill_selected_index]
	var autofill_arg = autofill_content_owners[autofill_selected_index]
	if autofill_arg.has_method("get_autofill_result"): 
		autofill_text = autofill_arg.get_autofill_result()
	terminal_panel.autofill_text(autofill_text)
	redraw_autofill_contents()

var autofill_contents : Array[String] = []
var autofill_content_owners : Array[Argument] = []
func update_autofill_content():
	if autofill_entries.is_empty() or not terminal_panel.terminal_line_edit.has_focus() or terminal_panel.terminal_line_edit.text.is_empty():
		self.visible = false
		return
	else:
		self.visible = true

	autofill_contents.clear()
	autofill_content_owners.clear()
	for index in range(0, len(autofill_entries)):
		var autofill_argument = autofill_entries[index]
		if autofill_argument.has_method("get_autofill_entry"):
			autofill_contents.append(autofill_argument.get_autofill_entry())
			autofill_content_owners.append(autofill_argument)
		elif autofill_argument.has_method("get_autofill_entries"):
			var entries : Array[String] = autofill_argument.get_autofill_entries()
			autofill_contents.append_array(entries)
			var arr = []
			arr.resize(len(entries))
			arr.fill(autofill_argument)
			autofill_content_owners.append_array(arr)
		else:
			autofill_contents.append(autofill_argument.to_string())
			autofill_content_owners.append(autofill_argument)

var previous_line_edit_contents : String = ""
func redraw_autofill_contents(line_edit_contents : String = previous_line_edit_contents):
	autofill_rich_label.clear()
	for index in range(0, len(autofill_contents)):
		var content = autofill_contents[index]
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
@onready var margins = margin_container.get_theme_constant("margin_left") + margin_container.get_theme_constant("margin_right") 

func update_autofill_position_and_size(line_edit_contents : String):
	var string_to_pad : String = " ".join(line_edit_contents.split(" ").slice(0, -1))
	var px_to_pad = command_line_font.get_string_size(
		string_to_pad,
		HORIZONTAL_ALIGNMENT_LEFT, 
		-1, 
		command_line_font_size
	).x
	
	var panel_size = command_line_font.get_multiline_string_size(
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
