#class_name CommandTerminalGuts
extends Node

@onready var command_terminal_node : CommandTerminal = self.get_parent()
@onready var terminal_line_edit : LineEdit = $"%TERMINAL-LINE-EDIT"
@onready var terminal_rich_label : RichTextLabel = $"%TERMINAL-RICH-LABEL"
@onready var autofill_rich_label : RichTextLabel = $"%AUTOFILL-RICH-LABEL"
@onready var autofill_panel : PanelContainer = $"%AUTOFILL-PANEL"

func _ready():
	var _console_key = ProjectSettings.get_setting("plugins/command_terminal/console_key_shortcut").duplicate()
	InputMap.add_action("ui_console")
	InputMap.action_add_event("ui_console", _console_key)
	CommandTerminalLogger.log(2, ["TERMINAL"], "Registered 'ui_console' to InputMap")

	terminal_line_edit.text_changed.connect(on_line_edit_new_text)
	terminal_line_edit.text_submitted.connect(run_command)

func on_line_edit_new_text(new_text : String):
	terminal_rich_label.text = terminal_line_edit.text
	autofill_rich_label.text = "dmx"
	update_autofill_position_and_size(new_text)

func run_command(text : String):
	terminal_line_edit.text = ""
	CommandServer.run_command(text)

@onready var command_line_font : Font = command_terminal_node.font
@onready var command_line_font_size : int = command_terminal_node.font_size
@onready var margin_container : MarginContainer = autofill_panel.get_node("MarginContainer") 
@onready var margins = margin_container.get_theme_constant("margin_left") + margin_container.get_theme_constant("margin_right") 

var autofill_candidates : Array[String] = []
var autofill_selected_index = 0

func _input(event):
	if not terminal_line_edit.has_focus(): return
	if event.is_action_pressed("ui_focus_prev"):
		update_autofill_index(false)
	elif event.is_action_pressed("ui_focus_next"):
		update_autofill_index()

func _process(delta):
	if Input.is_action_just_pressed("ui_console"):
		terminal_line_edit.grab_focus()
	if Input.is_action_just_pressed("ui_cancel"):
		if terminal_line_edit.has_focus():
			terminal_line_edit.release_focus()

func update_autofill_candidates(new_text):
	autofill_candidates = CommandServer.get_autofill_candidates(new_text)

func update_autofill_index(forward : bool = true):
	if forward:
		autofill_selected_index += 1
		if autofill_selected_index >= len(autofill_candidates):
			autofill_selected_index = 0
	else:
		autofill_selected_index -= 1
		if autofill_selected_index < 0:
			autofill_selected_index = len(autofill_candidates) - 1

	update_autofill_content()
	terminal_line_edit.text = terminal_rich_label.get_parsed_text()

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

func update_autofill_position_and_size(new_text : String):
	var string_to_pad = new_text.left(new_text.rfind(" ") + 1)
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

	autofill_panel.size = panel_size
	autofill_panel.position = Vector2(
		px_to_pad,
		-panel_size.y
	)
