#class_name CommandTokenizer
extends RefCounted

const _validated_argument_color_list : Array[String] = [
	"#5FFAF8",
	"#F7FB68",
	"#56F75A",
	"#EC57E8",
	"#EDAA13",
]

func tokenize(args : PackedStringArray) -> Array[CommandToken]:
	var tokens : Array[CommandToken] = []
	var validated_argument_count : int = 0
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Arguments recieved: [%s]" % [args]) 
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Preparing to tokenize.") 
	var state : Dictionary
	for arg in args:
		CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Tokenizing arg '%s'..." % [arg]) 
		state = tokenize_arg({
			"arg" : arg,
			"current_working_node" : state.get("current_working_node", CommandServer.argument_graph),
			"validated_argument_count" : state.get("validated_argument_count", validated_argument_count),
		})
		tokens.push_back(state["token"])
	return tokens

func tokenize_arg(data : Dictionary) -> Dictionary:
	var arg : String = data["arg"]
	var current_working_node : ArgumentNode = data["current_working_node"]
	var validated_argument_count : int = data["validated_argument_count"]
	var next_working_node : ArgumentNode = null
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Creating token...") 
	var token = CommandToken.new(
		"???",
		arg,
		null,
		null,
		Color.RED,
		false,
	)
	if current_working_node != null:
		for child in current_working_node.children:
			var argument : Argument = child.argument
			CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Checking argument '%s'..." % [argument]) 
			if argument.is_valid(arg) or argument.is_autofill_candidate(arg):
				token.name = argument.to_string()
				token.argument = argument
				token.node = child
				token.is_valid_or_approaching = true
			else:
				continue
			CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Valid, updated token.") 
			next_working_node = child
			CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Descending to ArgumentNode: %s" % [next_working_node])
			if argument is ValidatedArgument:
				validated_argument_count += 1
				token.color = _validated_argument_color_list[validated_argument_count % _validated_argument_color_list.size()]
			else:
				token.color = Color.WHITE
	return {
		"token" : token,
		"current_working_node" : next_working_node,
		"validated_argument_count" : validated_argument_count,
	}

class CommandToken extends RefCounted:
	var name : String
	var entry : String
	var argument : Argument
	var node : ArgumentNode
	var color : Color
	var is_valid_or_approaching : bool

	func _init(_name : String, _entry : String, _argument : Argument, _node : ArgumentNode, _color : Color, _is_valid_or_approaching : bool):
		name = _name
		entry = _entry
		argument = _argument
		node = _node
		color = _color
		is_valid_or_approaching = _is_valid_or_approaching

	func _to_string():
		return "CommandToken(%s, %s, %s, %s, %s, %s)" % [name, entry, argument, node, color, is_valid_or_approaching]

	func get_color_as_hex() -> String:
		return "#%02X%02X%02X" % [color.r * 255, color.g * 255, color.b * 255]