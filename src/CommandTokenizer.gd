#class_name CommandTokenizer
extends RefCounted

var command_server : CommandServer = null

func _init(_server_instance : CommandServer):
	command_server = _server_instance

func tokenize_text(text : String) -> Array[CommandToken]:
	return tokenize_args(command_server.get_arg_info_from_text(text)["args"])

func tokenize_args(args : PackedStringArray) -> Array[CommandToken]:
	return _cache(args)

var last_proc : PackedStringArray = []
var last_output : Array[CommandToken] = []
func _cache(args : PackedStringArray):
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Preparing to tokenize.") 
	if last_proc == args:
		CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Cache hit. Returning tokens: [%s]" % [last_output]) 
		return last_output
	last_proc = args
	last_output = _tokenize(args)
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Returning tokens: [%s]" % [last_output]) 
	return last_output

var current_working_node : ArgumentNode = null
var colored_arg_count : int = 0
func _tokenize(_input : String) -> Array[CommandToken]:
	var tokens : Array[CommandToken] = []
	colored_arg_count = 0
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Input recieved: [%s]" % [_input]) 
	current_working_node = command_server.argument_graph

	for child in current_working_node.children:
		var argument : Argument = child.argument
		var is_valid : bool = argument.is_valid(_input)

	for arg in args:
		CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Tokenizing arg '%s'..." % [arg]) 
		tokens.push_back(tokenize_arg(arg))
	return tokens

#TODO: new method for tokenizing args:
# 0. recurse through tree
# 1. if argument.get_satisfying_prefix != "", trim it, and repeat with children
# 2. else, ask it for get_autofill_candidates

func tokenize_arg(arg : String) -> CommandToken:
	var next_working_node : ArgumentNode = null
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Creating token...") 
	var token = CommandToken.new(
		"???",
		arg,
		null,
		null,
		Color.RED,
		false,
		false
	)
	if current_working_node != null:
		for child in current_working_node.children:
			var argument : Argument = child.argument
			CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Checking argument '%s'..." % [argument]) 
			if argument.has_method("is_valid"):
				if argument.is_valid(arg):
					_scribe_on_token(token, child)
					token.is_valid = true
					next_working_node = child
			elif argument.has_method("is_autofill_candidate"):
				if argument.is_autofill_candidate(arg):
					_scribe_on_token(token, child)
					token.is_approaching = true
					next_working_node = child
			else:
				continue
	if token.argument is ValidatedArgument or token.argument is KeyArgument:
		colored_arg_count += 1
		token.color = _COLORED_ARGS_COLOR_LIST[colored_arg_count % _COLORED_ARGS_COLOR_LIST.size()]
	else:
		if token.is_valid:
			token.color = Color.WHITE
	current_working_node = next_working_node
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Created token: %s" % [token])
	return token

func _scribe_on_token(token, child):
	var argument = child.argument
	token.name = argument.to_string()
	token.argument = argument
	token.node = child

const _COLORED_ARGS_COLOR_LIST : Array[String] = [
	"#5FFAF8",
	"#F7FB68",
	"#56F75A",
	"#EC57E8",
	"#EDAA13",
]

class CommandToken extends RefCounted:
	var name : String
	var entry : String
	var argument : Argument
	var node : ArgumentNode
	var color : Color
	var is_valid : bool
	var is_approaching : bool

	func _init(_name : String, _entry : String, _argument : Argument, _node : ArgumentNode, _color : Color, _is_valid: bool, _is_approaching: bool):
		name = _name
		entry = _entry
		argument = _argument
		node = _node
		color = _color
		is_valid = _is_valid
		is_approaching = _is_approaching

	func _to_string():
		return "CommandToken(%s, %s, %s, %s, %s, %s, %s)" % [name, entry, argument, node, color, is_valid, is_approaching]

	func get_color_as_hex() -> String:
		return "#%02X%02X%02X" % [color.r * 255, color.g * 255, color.b * 255]
