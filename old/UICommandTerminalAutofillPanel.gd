#class_name UICommandTerminalAutofillPanel
extends Control

@export var command_line_entry : LineEdit
@export var command_line : RichTextLabel

func _ready():
	command_line_entry.text_changed.connect(func(new_text : String):
		update_autofill_list(new_text)
		update_autofill_content()
		update_autofill_position(new_text)
	)

func _input(event):
	if not command_line_entry.has_focus(): return
	if event.is_action_pressed("ui_focus_prev"):
		update_autofill_index(false)
	elif event.is_action_pressed("ui_focus_next"):
		update_autofill_index()

var autofill_list : Array[String] = []
var autofill_selected_index = 0

func update_autofill_list(new_text):
	autofill_list = CommandServer.get_autofill_list(new_text)
	autofill_list_updated.emit(autofill_list)

signal autofill_list_updated(autofill_list : Array[String])

func update_autofill_index(forward : bool = true):
	if forward:
		autofill_selected_index += 1
		if autofill_selected_index >= len(autofill_list):
			autofill_selected_index = 0
	else:
		autofill_selected_index -= 1
		if autofill_selected_index < 0:
			autofill_selected_index = len(autofill_list) - 1

	update_autofill_content()

@export var autofill_menu_panel : PanelContainer
@export var autofill_text : RichTextLabel

func update_autofill_content():
	if autofill_list.is_empty():
		self.visible = false
		return
	else:
		self.visible = true

	autofill_text.clear()
	for index in range(0, len(autofill_list)):
		var entry = autofill_list[index]
		if index == autofill_selected_index:
			autofill_text.push_color(Color.YELLOW)
			autofill_text.append_text(entry)
			autofill_text.pop()
		else:
			autofill_text.append_text(entry)
		autofill_text.append_text("\n")
	
@onready var command_line_font : Font = self.get_parent().font
@onready var command_line_font_size : int = command_line.get("theme_override_font_sizes/normal_font_size")
@onready var margin_container : MarginContainer = autofill_menu_panel.get_node("MarginContainer") 
@onready var margins = margin_container.get_theme_constant("margin_left") + margin_container.get_theme_constant("margin_right") 


func update_autofill_position(new_text : String):
	var string_to_pad = new_text.left(new_text.rfind(" ") + 1)
	var px_to_pad = command_line_font.get_string_size(
		string_to_pad,
		HORIZONTAL_ALIGNMENT_LEFT, 
		-1, 
		command_line_font_size
	).x
	
	var panel_size = command_line_font.get_multiline_string_size(
		autofill_text.get_parsed_text(), 
		HORIZONTAL_ALIGNMENT_LEFT, 
		-1, 
		command_line_font_size
	) + Vector2(margins, margins)

	self.size = panel_size
	self.position = Vector2(
		px_to_pad,
		-panel_size.y
	)
	
