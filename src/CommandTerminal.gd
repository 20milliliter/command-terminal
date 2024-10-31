@icon("res://addons/command-terminal/ast/CommandTerminal.svg")
@tool
## A control that displays a UI for entering and running commands
##
## A control that displays a UI for entering and running commands. It accesses the plugin's CommandServer singleton.
class_name CommandTerminal
extends Control

@export_group("Font")
## The font to use in the terminal.
@export var font : Font = load("res://addons/command-terminal/ast/windows_command_prompt.ttf")
## The font size to use in the terminal.
@export var font_size : int = 12

@export_group("Theming")
## The [StyleBox]es to use for the terminal panel.
@export var terminal_panel_styling : StyleBox
## The [StyleBox]es to use for the autocomplete panel.
@export var autocomplete_panel_styling : StyleBox

var guts : Node

func _ready():
	_first_time_setup()
	_handle_editor_functions()

func _process(_delta : float) -> void:
	_handle_editor_properties()
	_handle_functions()
	if not Engine.is_editor_hint(): return
	_handle_editor_functions()

func _first_time_setup() -> void:
	if guts != null: return
	if self.has_node("__guts__"): 
		guts = self.get_node("__guts__")
		return

	var guts_scene : PackedScene = load("res://addons/command-terminal/scn/command_terminal_guts.tscn")
	guts = guts_scene.instantiate()
	self.add_child(guts)
	guts.set_owner(get_tree().get_edited_scene_root())

	guts.set_anchors_and_offsets_preset.call_deferred(PRESET_FULL_RECT)
	self.set_anchors_and_offsets_preset.call_deferred(PRESET_BOTTOM_WIDE)

func _handle_functions() -> void:
	var terminal_line_edit = guts.find_child("TERMINAL-LINE-EDIT", true, false)
	var terminal_rich_label = guts.find_child("TERMINAL-RICH-LABEL", true, false)
	terminal_line_edit.set_anchors_and_offsets_preset(PRESET_HCENTER_WIDE)
	terminal_rich_label.set_anchors_and_offsets_preset(PRESET_HCENTER_WIDE)

func _handle_editor_functions() -> void:
	if self.size.y < 15:
		self.position.y -= 15 - self.size.y
		self.size.y = 15
	var autocomplete_panel = guts.find_child("AUTOCOMPLETE-PANEL", true, false)
	var terminal_panel = guts.find_child("TERMINAL-PANEL", true, false)
	var terminal_panel_rect = terminal_panel.get_rect()
	autocomplete_panel.size = Vector2(0, terminal_panel_rect.size.y)
	autocomplete_panel.position = -Vector2(0, terminal_panel_rect.size.y)

func _handle_editor_properties() -> void:
	if autocomplete_panel_styling:
		guts.get_node("%AUTOCOMPLETE-PANEL").add_theme_stylebox_override("panel", autocomplete_panel_styling)
	else:
		guts.get_node("%AUTOCOMPLETE-PANEL").remove_theme_stylebox_override("panel")

	if terminal_panel_styling:
		guts.get_node("%TERMINAL-PANEL").add_theme_stylebox_override("panel", terminal_panel_styling)
		guts.get_node("%TERMINAL-PANEL").add_theme_stylebox_override("panel", terminal_panel_styling)
	else:
		guts.get_node("%TERMINAL-PANEL").remove_theme_stylebox_override("panel")
		guts.get_node("%TERMINAL-PANEL").remove_theme_stylebox_override("panel")
	
	if font_size:
		guts.get_node("%AUTOCOMPLETE-RICH-LABEL").add_theme_font_size_override("normal_font_size", font_size)
		guts.get_node("%TERMINAL-RICH-LABEL").add_theme_font_size_override("normal_font_size", font_size)
		guts.get_node("%TERMINAL-LINE-EDIT").add_theme_font_size_override("font_size", font_size)
	else:
		guts.get_node("%AUTOCOMPLETE-RICH-LABEL").remove_theme_font_size_override("normal_font_size")
		guts.get_node("%TERMINAL-RICH-LABEL").remove_theme_font_size_override("normal_font_size")
		guts.get_node("%TERMINAL-LINE-EDIT").remove_theme_font_size_override("font_size")
		
	if font:
		guts.get_node("%AUTOCOMPLETE-RICH-LABEL").add_theme_font_override("normal_font", font)
		guts.get_node("%TERMINAL-RICH-LABEL").add_theme_font_override("normal_font", font)
		guts.get_node("%TERMINAL-LINE-EDIT").add_theme_font_override("font", font)
	else:
		guts.get_node("%AUTOCOMPLETE-RICH-LABEL").remove_theme_font_override("normal_font")
		guts.get_node("%TERMINAL-RICH-LABEL").remove_theme_font_override("normal_font")
		guts.get_node("%TERMINAL-LINE-EDIT").remove_theme_font_override("font")
