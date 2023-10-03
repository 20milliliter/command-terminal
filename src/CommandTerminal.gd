@icon("res://addons/command-terminal/CommandTerminal.svg")
@tool
class_name CommandTerminal 
extends Control

@export_group("Themeing")
@export var font : Font
@export var font_size : int
@export var terminal_panel_styling : StyleBox
@export var autofill_panel_styling : StyleBox

var guts : Node

func _enter_tree():
	if self.has_node("__guts__"): return

	var guts_scene : PackedScene = preload("res://addons/command-terminal/scn/command_terminal_guts.tscn")
	guts = guts_scene.instantiate()
	self.add_child(guts)
	
	guts.call_deferred("set_anchors_and_offsets_preset", PRESET_FULL_RECT)
	self.call_deferred("set_anchors_and_offsets_preset", PRESET_BOTTOM_WIDE)

func _ready():
	if Engine.is_editor_hint(): return
	_save_bounds()

func _process(delta):
	if Engine.is_editor_hint(): return
	_fix_altered_bounds()

var saved_size : Vector2
var saved_position : Vector2
var bounds_repaired : bool = false

func _save_bounds():
	saved_size = self.size
	saved_position = self.position

func _fix_altered_bounds():
	if bounds_repaired: return
	if self.size != saved_size:
		self.size = saved_size
		self.position = saved_position
		bounds_repaired = true