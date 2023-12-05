class_name CommandTokenizer
extends RefCounted

const _validated_argument_color_list : Array[String] = [
	"#5FFAF8",
	"#F7FB68",
	"#56F75A",
	"#EC57E8",
	"#EDAA13",
]

static func tokenize(text : String) -> Array[CommandToken]:
	var tokens : Array[CommandToken] = []
	var text_args : PackedStringArray = text.split(" ")
	var args : Array[String] = []
	for arg in text_args:
		args.push_back(arg)
	var argument_graph : ArgumentGraph = CommandServer.argument_graph
	var currently_working_node : ArgumentNode = argument_graph
	var validated_argument_count : int = 0
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Preparing to tokenize.") 
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Arguments recieved: [%s]" % [args]) 
	while len(currently_working_node.children) > 0:
		var token : CommandToken = null
		for child in currently_working_node.children:
			var argument : Argument = child.argument
			CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Checking argument '%s'..." % [argument]) 
			if argument is GroupArgument:
				var num_group_args : int = len(argument.arguments)
				var args_string : String = " ".join(args.slice(0, num_group_args))
				if argument.is_valid(args_string):
					CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Valid, creating token...") 
					token = CommandToken.new(
						argument.to_string(),
						args_string,
						argument,
						child,
						_validated_argument_color_list[validated_argument_count],
						true,
					)
					args = args.slice(num_group_args)
					currently_working_node = child
					validated_argument_count += 1
					break
			elif argument is ValidatedArgument:
				if argument.is_valid(args.front()):
					CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Valid, creating token...") 
					token = CommandToken.new(
						argument.to_string(),
						args.front(),
						argument,
						child,
						_validated_argument_color_list[validated_argument_count],
						true,
					)
					args.pop_front()
					currently_working_node = child
					validated_argument_count += 1
					break
			else:
				if argument.is_valid(args.front()):
					CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Valid, creating token...") 
					token = CommandToken.new(
						argument.to_string(),
						args.front(),
						argument,
						child,
						"#FFFFFF",
						true,
					)
					args.pop_front()
					currently_working_node = child
					break
					
		if token == null:
			for arg in args:
				CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Invalid, creating token...") 
				tokens.push_back(CommandToken.new(
					"???",
					arg,
					null,
					null,
					"#FF0000",
					false,
				))
			CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Exiting.") 
			return tokens
		CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Descending...") 
		CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "New ArgumentNode: %s" % [currently_working_node]) 
		CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Remaining Arguments: [%s]" % [args]) 
		tokens.push_back(token)
	return tokens

