@icon("res://addons/command-terminal/CommandTerminal.svg")
#class_name CommandTerminal 
extends PanelContainer
## A brief description of the class's role and functionality.

@export var command_line : RichTextLabel
@export var command_line_entry : LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	command_line_entry.text_changed.connect(update_commandline_content)
	command_line_entry.text_submitted.connect(process_command)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_console"): command_line_entry.grab_focus()
	
func update_commandline_content(new_text : String):
	command_line.clear()
	var text : String = ""
	var args : PackedStringArray = new_text.split(" ")
	for arg_index in range(0, len(args)):
		var arg = args[arg_index]
		if arg_index == len(args) - 1:
			if len([]) == 0:
				command_line.push_color(Color.RED)
			else:
				command_line.push_color(Color.CYAN)
			command_line.append_text(arg)
			command_line.pop()
		else:
			command_line.append_text(arg)
		command_line.append_text(" ")
	text = text.replace("[", "[lb]")
	command_line.text = text 

func process_command(command : String):
	print_rich(command)
	command_line.text = ""
	command_line_entry.text = ""
	command_line_entry.release_focus()
