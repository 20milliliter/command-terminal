class_name CommandTerminalTerminalPanel
extends PanelContainer

@onready var command_terminal_guts : CommandTerminalGuts = self.get_parent().get_parent()
@onready var autofill_panel = command_terminal_guts.autofill_panel

@onready var terminal_line_edit : LineEdit = $"%TERMINAL-LINE-EDIT"
@onready var terminal_rich_label : RichTextLabel = $"%TERMINAL-RICH-LABEL"

signal contents_altered(new_contents : String)
signal command_ran(command : String)

func _ready():
	terminal_line_edit.text_changed.connect(
		func(t): 
			_on_contents_altered(t)
			contents_altered.emit(t)
	)
	terminal_line_edit.text_submitted.connect(
		func(t): 
			terminal_line_edit.text = ""
			command_ran.emit(t)
	)

func _on_contents_altered(new_contents : String):
	terminal_rich_label.text = new_contents

func _input(event):
	#if not terminal_line_edit.has_focus(): return
	if event.is_action_pressed("ui_focus_prev"):
		autofill_panel.advance_autofill_index()
	elif event.is_action_pressed("ui_focus_next"):
		autofill_panel.reverse_autofill_index()

func _process(delta):
	if Input.is_action_just_pressed("ui_console"):
		terminal_line_edit.grab_focus()
	elif Input.is_action_just_pressed("ui_cancel"):
		if terminal_line_edit.has_focus():
			terminal_line_edit.release_focus()
