class_name CommandTerminalTerminalPanel
extends PanelContainer

@onready var command_terminal_guts : CommandTerminalGuts = self.get_parent().get_parent()
@onready var autofill_panel : CommandTerminalAutofillPanel = command_terminal_guts.autofill_panel

@onready var terminal_line_edit : LineEdit = $"%TERMINAL-LINE-EDIT"
@onready var terminal_rich_label : RichTextLabel = $"%TERMINAL-RICH-LABEL"

signal contents_altered(new_contents : String)
signal command_ran(command : String)

func _ready():
	terminal_line_edit.text_changed.connect(
		func(t): 
			terminal_rich_label.text = _paint_terminal_text(t)
			contents_altered.emit(t)
			append_autofill_suggestion.call_deferred()
			pre_autofilled_text = t
	)
	terminal_line_edit.text_submitted.connect(
		func(t): 
			terminal_line_edit.text = ""
			terminal_rich_label.text = ""
			CommandTerminalLogger.log(2, ["TERMINAL"], "Terminal submitted with: '%s'." % [t]) 
			command_ran.emit(t)
			terminal_line_edit.text_changed.emit("")
	)
	terminal_line_edit.focus_entered.connect(autofill_panel.redraw_autofill_contents)
	terminal_line_edit.focus_exited.connect(autofill_panel.redraw_autofill_contents)

func _paint_terminal_text(text : String):
	var tokentree : CommandTokenizer.TokenTreeNode = command_terminal_guts.tokenizer_cache(text)
	CommandTerminalLogger.log(2, ["TERMINAL","PAINTING"], "Painting '%s'." % [text]) 
	var paints : Array[String] = []
	var working_tree_node = tokentree
	while working_tree_node.children.size() > 0:
		working_tree_node = working_tree_node.children[0]
		paints.append(_paint_token(working_tree_node.token))
	CommandTerminalLogger.log(3, ["TERMINAL","PAINTING"], "Output: '%s'." % [paints]) 
	var output : String = " ".join(paints)
	return output

func _paint_token(token : CommandTokenizer.Token) -> String:
	return "[color=%s]%s[/color]" % [token.get_color_as_hex(), token.content]

func append_autofill_suggestion():
	var contents = autofill_panel.autofill_entries
	var owners = autofill_panel.autofill_entry_owners
	if contents.is_empty(): return
	if owners[0] is PeculiarArgument: return
	var autofill_result : String = contents[0]
	var args = terminal_line_edit.text.split(" ")
	var last_arg : String = args[len(args) - 1]
	var remaining_arg_text = autofill_result.right(-len(last_arg))
	terminal_rich_label.push_color(Color(1, 1, 1, 0.25))
	terminal_rich_label.append_text(remaining_arg_text)
	terminal_rich_label.pop()

var pre_autofilled_text : String = ""
func autofill_text(argument : String):
	var complete_args : Array[String] = command_terminal_guts.get_all_complete_args(pre_autofilled_text)
	var autofilled = " ".join(complete_args + [argument])
	CommandTerminalLogger.log(2, ["TERMINAL", "AUTOFILL"], "Autofilled '%s'." % [autofilled])
	terminal_rich_label.text = _paint_terminal_text(autofilled)
	terminal_line_edit.text = autofilled
	terminal_line_edit.caret_column = autofilled.length()
	
func _input(event):
	#if not terminal_line_edit.has_focus(): return
	if event.is_action_pressed("ui_focus_prev"):
		autofill_panel.advance_autofill_index()
	elif event.is_action_pressed("ui_focus_next"):
		autofill_panel.reverse_autofill_index()

func _process(delta):
	if Input.is_action_just_pressed("ui_console"):
		terminal_line_edit.grab_focus()
