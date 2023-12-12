class_name CommandTerminalAutofillPanel
extends PanelContainer

@onready var command_terminal_guts : CommandTerminalGuts = self.get_parent().get_parent()
@onready var terminal_panel : CommandTerminalTerminalPanel = command_terminal_guts.terminal_panel
@onready var autofill_rich_label : RichTextLabel = $"%AUTOFILL-RICH-LABEL"

var existing_char_count : int = 0
func _ready():
	terminal_panel.contents_altered.connect(
		func(new_contents):
			var char_count = len(new_contents)
			if char_count > existing_char_count and len(autofill_contents) > 0 and not new_contents.ends_with(" "):
				prune_autofill_content(new_contents)
			else:
				refresh_autofill_contents(new_contents)
			redraw_autofill_contents()
	)

func refresh_autofill_contents(new_text : String):
	update_autofill_candidates(new_text)
	autofill_selected_index = -1
	update_autofill_content()
	redraw_autofill_contents(new_text)

var autofill_candidates : Array[Argument] = []
func update_autofill_candidates(new_text : String):
	var working_node : ArgumentNode = CommandServer.get_working_argumentnode(new_text)
	var children : Array[ArgumentNode] = []
	if not working_node == null:
		children = working_node.children
	var args : Array[Argument] = []
	for child in children:
		args.append(child.argument)
	autofill_candidates = args

var autofill_selected_index = 0
func advance_autofill_index(): _change_autofill_index(true)
func reverse_autofill_index(): _change_autofill_index(false)
func _change_autofill_index(forward : bool):
	if autofill_contents.is_empty(): return
	autofill_selected_index -= 1 if forward else -1
	autofill_selected_index = wrapi(autofill_selected_index, 0, len(autofill_contents))
	var autofill_text = autofill_contents[autofill_selected_index]
	var autofill_arg = autofill_content_owners[autofill_selected_index]
	if autofill_arg.has_method("get_autofill_result"): 
		autofill_text = autofill_arg.get_autofill_result()
	terminal_panel.autofill_text(autofill_text)
	redraw_autofill_contents()

var autofill_contents : Array[String] = []
var autofill_content_owners : Array[Argument] = []
func update_autofill_content():
	if autofill_candidates.is_empty() or not terminal_panel.terminal_line_edit.has_focus() or terminal_panel.terminal_line_edit.text.is_empty():
		self.visible = false
		return
	else:
		self.visible = true

	autofill_contents.clear()
	autofill_content_owners.clear()
	for index in range(0, len(autofill_candidates)):
		var autofill_argument = autofill_candidates[index]
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

func prune_autofill_content(line_edit_contents : String):
	var incomplete_arg = CommandServer.get_arg_info_from_text(line_edit_contents)["incomplete_arg"]
	var contents_copy = autofill_contents.duplicate()
	var owners_copy = autofill_content_owners.duplicate()
	for index in range(0, len(autofill_contents)):
		var content = autofill_contents[index]
		var owner = autofill_content_owners[index]
		var will_prune = false

		if owner.has_method("is_autofill_candidate"):
			if not owner.is_autofill_candidate(incomplete_arg):
				will_prune = true
		elif not content.begins_with(incomplete_arg):
			will_prune = true

		if will_prune:
			#print("Pruned '%s' from autofill" % [content]) 
			contents_copy.erase(content)
			owners_copy.erase(owner)

	autofill_contents = contents_copy
	autofill_content_owners = owners_copy

var previous_line_edit_contents : String = ""
func redraw_autofill_contents(line_edit_contents : String = previous_line_edit_contents):
	autofill_rich_label.clear()
	previous_line_edit_contents = line_edit_contents
	for index in range(0, len(autofill_contents)):
		var content = autofill_contents[index]
		if index == autofill_selected_index:
			autofill_rich_label.push_color(Color.YELLOW)
			autofill_rich_label.append_text(content)
			autofill_rich_label.pop()
		else:
			autofill_rich_label.append_text(content)
		autofill_rich_label.append_text("\n")
	update_autofill_position_and_size(line_edit_contents)

@onready var command_line_font : Font = command_terminal_guts.parent_node.font
@onready var command_line_font_size : int = command_terminal_guts.parent_node.font_size
@onready var margin_container : MarginContainer = self.get_node("MarginContainer") 
@onready var margins = margin_container.get_theme_constant("margin_left") + margin_container.get_theme_constant("margin_right") 

func update_autofill_position_and_size(line_edit_contents : String):
	var complete_args = CommandServer.get_arg_info_from_text(line_edit_contents)["complete_args"]
	var string_to_pad = " ".join(complete_args)
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
