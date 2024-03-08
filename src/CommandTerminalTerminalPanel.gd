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
	)
	terminal_line_edit.text_submitted.connect(
		func(t): 
			terminal_line_edit.text = ""
			terminal_rich_label.text = ""
			command_ran.emit(t)
			terminal_line_edit.text_changed.emit("")
	)
	terminal_line_edit.focus_entered.connect(autofill_panel.update_autofill_content)
	terminal_line_edit.focus_exited.connect(autofill_panel.update_autofill_content)

func _paint_terminal_text(text : String):
	var tokentree : CommandTokenizer.TokenTreeNode = command_terminal_guts.tokenizer_cache(text)
	CommandTerminalLogger.log(3, ["COMMAND","PAINTING"], "Painting '%s'." % [text]) 
	var paints : Array[String] = _paint_tokennodes_recursive(tokentree)
	CommandTerminalLogger.log(3, ["COMMAND","PAINTING"], "Tokens: '%s'." % [paints]) 
	var output : String = " ".join(paints)
	CommandTerminalLogger.log(3, ["COMMAND","PAINTING"], "Output: '%s'." % [output]) 
	return output

func _paint_tokennodes_recursive(tokentreenode : CommandTokenizer.TokenTreeNode) -> Array[String]:
	var token = tokentreenode.token
	var token_strings : Array[String] = []
	if not token is CommandTokenizer.RootToken:
		token_strings.append(_paint_token(token))
	for childnode in tokentreenode.children:
		token_strings.append_array(_paint_tokennodes_recursive(childnode))
	return token_strings

func _paint_token(token : CommandTokenizer.Token) -> String:
	return "[color=%s]%s[/color]" % [token.get_color_as_hex(), token.content]

func append_autofill_suggestion():
	var contents = autofill_panel.autofill_contents
	if contents.is_empty(): return
	var autofill_argument = autofill_panel.autofill_content_owners[0]
	var autofill_result : String = autofill_panel.autofill_contents[0]
	if autofill_argument.has_method("get_autofill_result"):
		autofill_result = autofill_argument.get_autofill_result()
	var args = terminal_line_edit.text.split(" ")
	var last_arg : String = args[len(args) - 1]
	var remaining_arg_text = autofill_result.right(-len(last_arg))
	terminal_rich_label.push_color(Color(1, 1, 1, 0.25))
	terminal_rich_label.append_text(remaining_arg_text)
	terminal_rich_label.pop()

func autofill_text(argument : String):
	var existing = terminal_line_edit.text
	var all_complete_args = existing.left(existing.rfind(" ") + 1)
	var autofilled = all_complete_args + argument
	terminal_rich_label.text = _paint_terminal_text(autofilled)
	terminal_line_edit.text = autofilled
	terminal_line_edit.caret_column = autofilled.length()
	CommandTerminalLogger.log(2, ["COMMAND","TERMINAL","AUTOFILL"], "Autofilled argument '%s'." % [argument])
	
func _input(event):
	#if not terminal_line_edit.has_focus(): return
	if event.is_action_pressed("ui_focus_prev"):
		autofill_panel.advance_autofill_index()
	elif event.is_action_pressed("ui_focus_next"):
		autofill_panel.reverse_autofill_index()

func _process(delta):
	if Input.is_action_just_pressed("ui_console"):
		terminal_line_edit.grab_focus()
