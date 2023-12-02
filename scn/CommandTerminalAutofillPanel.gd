class_name CommandTerminalAutofillPanel
extends PanelContainer

@onready var command_terminal_guts : CommandTerminalGuts = self.get_parent().get_parent()
@onready var terminal_panel : CommandTerminalTerminalPanel = command_terminal_guts.terminal_panel
@onready var autofill_rich_label : RichTextLabel = $"%AUTOFILL-RICH-LABEL"

func _ready():
	terminal_panel.contents_altered.connect(refresh_autofill_contents)

func refresh_autofill_contents(new_text : String):
	update_autofill_candidates(new_text)
	autofill_selected_index = -1
	update_autofill_content()
	update_autofill_position_and_size(new_text)

var autofill_candidates : Array[String] = []
func update_autofill_candidates(new_text):
	autofill_candidates = CommandServer.get_autofill_candidates(new_text)

var autofill_selected_index = 0
func advance_autofill_index(): _change_autofill_index(true)
func reverse_autofill_index(): _change_autofill_index(false)
func _change_autofill_index(forward : bool):
	autofill_selected_index += 1 if forward else -1
	autofill_selected_index = clamp(autofill_selected_index, 0, len(autofill_candidates) - 1)
	update_autofill_content()

func update_autofill_content():
	if autofill_candidates.is_empty():
		self.visible = false
		return
	else:
		self.visible = true

	autofill_rich_label.clear()
	for index in range(0, len(autofill_candidates)):
		var entry = autofill_candidates[index]
		if index == autofill_selected_index:
			autofill_rich_label.push_color(Color.YELLOW)
			autofill_rich_label.append_text(entry)
			autofill_rich_label.pop()
		else:
			autofill_rich_label.append_text(entry)
		autofill_rich_label.append_text("\n")

@onready var command_line_font : Font = command_terminal_guts.parent_node.font
@onready var command_line_font_size : int = command_terminal_guts.parent_node.font_size
@onready var margin_container : MarginContainer = self.get_node("MarginContainer") 
@onready var margins = margin_container.get_theme_constant("margin_left") + margin_container.get_theme_constant("margin_right") 

func update_autofill_position_and_size(new_text : String):
	var args = new_text.split(" ")
	var complete_args = args.slice(0, -1)
	var incomplete_arg = args[-1]

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
