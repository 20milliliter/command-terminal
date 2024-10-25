class_name CommandTerminalTerminalPanel
extends PanelContainer

@onready var command_terminal_guts : CommandTerminalGuts = self.get_parent().get_parent()
@onready var autofill_panel : CommandTerminalAutofillPanel = command_terminal_guts.autofill_panel

@onready var terminal_line_edit : LineEdit = $"%TERMINAL-LINE-EDIT"
@onready var terminal_rich_label : RichTextLabel = $"%TERMINAL-RICH-LABEL"

signal contents_altered(new_contents : String)
signal command_ran(command : String)
var last_ran_command : String = ""

func _ready() -> void:
	terminal_line_edit.text_changed.connect(
		func(t : String) -> void: 
			terminal_rich_label.text = _paint_terminal_text(t)
			contents_altered.emit(t)
			append_autofill_suggestion.call_deferred()
			pre_autofilled_text = t
	)
	terminal_line_edit.text_submitted.connect(
		func(t : String) -> void: 
			terminal_line_edit.text = ""
			terminal_rich_label.text = ""
			CommandTerminalLogger.log(2, ["TERMINAL"], "Terminal submitted with: '%s'." % [t]) 
			last_ran_command = t
			command_ran.emit(t)
			terminal_line_edit.text_changed.emit("")
	)
	terminal_line_edit.focus_entered.connect(autofill_panel.redraw_autofill_contents)
	terminal_line_edit.focus_exited.connect(autofill_panel.redraw_autofill_contents)

	terminal_line_edit.clear()
	terminal_rich_label.clear()

func _paint_terminal_text(text : String) -> String:
	var tokentree : CommandTokenizer.TokenTreeNode = command_terminal_guts.tokenizer_cache(text)
	if tokentree == null: return text
	CommandTerminalLogger.log(2, ["TERMINAL","PAINTING"], "Painting '%s'." % [text]) 
	var paints : Array[String] = []
	var working_tree_node : CommandTokenizer.TokenTreeNode = tokentree
	while working_tree_node.children.size() > 0:
		working_tree_node = working_tree_node.children[0]
		paints.append(_paint_token(working_tree_node.token))
	CommandTerminalLogger.log(3, ["TERMINAL","PAINTING"], "Output: '%s'." % [paints]) 
	var output : String = " ".join(paints)
	return output

func _paint_token(token : CommandTokenizer.Token) -> String:
	return "[color=%s]%s[/color]" % [token.get_color_as_hex(), token.content]

func append_autofill_suggestion() -> void:
	var contents : Array[String] = autofill_panel.autofill_entries
	var owners : Array[Argument] = autofill_panel.autofill_entry_owners
	if contents.is_empty(): return
	if owners[0] is PeculiarArgument: return
	var autofill_result : String = contents[0]
	var args : Array[String] = []
	args.assign(terminal_line_edit.text.split(" "))
	var last_arg : String = args[len(args) - 1]
	var remaining_arg_text : String = autofill_result.right(-len(last_arg))
	terminal_rich_label.push_color(Color(1, 1, 1, 0.25))
	terminal_rich_label.append_text(remaining_arg_text)
	terminal_rich_label.pop()

var pre_autofilled_text : String = ""
func autofill_text(argument : String) -> void:
	var complete_args : Array[String] = command_terminal_guts.get_all_complete_args(pre_autofilled_text)
	var autofilled : String = " ".join(complete_args + [argument])
	CommandTerminalLogger.log(2, ["TERMINAL", "AUTOFILL"], "Autofilled '%s'." % [autofilled])
	terminal_rich_label.text = _paint_terminal_text(autofilled)
	terminal_line_edit.text = autofilled
	terminal_line_edit.caret_column = autofilled.length()
	
func _input(event : InputEvent) -> void:
	if not terminal_line_edit.has_focus(): return
	if event.is_action_pressed("ui_focus_prev"):
		autofill_panel.advance_autofill_index()
		self.get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_focus_next"):
		autofill_panel.reverse_autofill_index()
		self.get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		terminal_line_edit.clear()
		terminal_line_edit.insert_text_at_caret(last_ran_command)
		terminal_line_edit.text_changed.emit(last_ran_command)
		self.get_viewport().set_input_as_handled()


func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("ui_console"):
		var window_owner : Window = get_tree().get_root()
		window_owner.grab_focus() #TODO: project setting conditional
		terminal_line_edit.grab_focus()
