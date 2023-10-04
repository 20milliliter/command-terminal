@icon("res://addons/command-terminal/ast/CommandTerminal.svg")
@tool
class_name CommandTerminal 
extends Control

@export_group("Font")
@export var font : Font = preload("res://addons/command-terminal/ast/windows_command_prompt.ttf")
@export var font_size : int = 12

@export_group("Theming")
@export var terminal_panel_styling : StyleBox
@export var autofill_panel_styling : StyleBox

var guts : Node

func _enter_tree():
	_first_time_setup()

func _process(delta):
	_handle_editor_properties()

func _first_time_setup():
	if self.has_node("__guts__"): 
		guts = self.get_node("__guts__")
		return

	var guts_scene : PackedScene = preload("res://addons/command-terminal/scn/command_terminal_guts.tscn")
	guts = guts_scene.instantiate()
	self.add_child(guts)
	guts.set_owner(get_tree().get_edited_scene_root())

	guts.call_deferred("set_anchors_and_offsets_preset", PRESET_FULL_RECT)
	self.call_deferred("set_anchors_and_offsets_preset", PRESET_BOTTOM_WIDE)

func _handle_editor_properties():
	if autofill_panel_styling:
		guts.get_node("%AutofillPanel").add_theme_stylebox_override("panel", autofill_panel_styling)
	else:
		guts.get_node("%AutofillPanel").remove_theme_stylebox_override("panel")

	if terminal_panel_styling:
		guts.get_node("%TerminalPanel").add_theme_stylebox_override("panel", terminal_panel_styling)
	else:
		guts.get_node("%TerminalPanel").remove_theme_stylebox_override("panel")
	
	if font_size:
		guts.get_node("%AutofillRichLabel").add_theme_font_size_override("normal_font_size", font_size)
		guts.get_node("%TerminalRichLabel").add_theme_font_size_override("normal_font_size", font_size)
		guts.get_node("%TerminalLineEdit").add_theme_font_size_override("font_size", font_size)
	else:
		guts.get_node("%AutofillRichLabel").remove_theme_font_size_override("normal_font_size")
		guts.get_node("%TerminalRichLabel").remove_theme_font_size_override("normal_font_size")
		guts.get_node("%TerminalLineEdit").remove_theme_font_size_override("font_size")
		
	if font:
		guts.get_node("%AutofillRichLabel").add_theme_font_override("normal_font", font)
		guts.get_node("%TerminalRichLabel").add_theme_font_override("normal_font", font)
		guts.get_node("%TerminalLineEdit").add_theme_font_override("font", font)
	else:
		guts.get_node("%AutofillRichLabel").remove_theme_font_override("normal_font")
		guts.get_node("%TerminalRichLabel").remove_theme_font_override("normal_font")
		guts.get_node("%TerminalLineEdit").remove_theme_font_override("font")