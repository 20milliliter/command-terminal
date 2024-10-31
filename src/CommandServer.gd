#class_name CommandServer
extends Node
## The singleton that is the interface between the command-terminal plugin and the rest of the codebase.
##
## The CommandServer is a singleton that is the interface between the command-terminal plugin, the CommandTerminal control node, and the rest of the codebase.
## It is responsible for registering commands, running commands, and handling errors.

var argument_graph : ArgumentGraph = ArgumentGraph.new()

## Registers a new command with the CommandServer. Takes an ArgumentGraph to represent the command.
## Use the provided [CommandBuilder] class to create an ArgumentGraph.
func register_command(command_graph : ArgumentGraph) -> void:
	CommandTerminalLogger.log(1, ["COMMAND"], "Registering command '%s'." % [command_graph.print_node_as_single()])
	#if ArgumentGraphValidator.is_valid_graph(command_graph)
	argument_graph.merge(command_graph)

var parsers : Dictionary = {} #[StringName, Callable]
## Registers a new parser with the CommandServer. Takes a StringName of the type to parse and the callable to call.
## Provided callable should take only one argument, a String, and return type specified by `type`.
func register_parser(type : StringName, parser : Callable) -> void:
	parsers[type] = parser

## Runs a command. Takes a string as input.
## The CommandTerminal control node handles running commands by itself, but this may be used if you want to run a command from elsewhere.
func run_command(command : String) -> void:
	CommandTerminalLogger.log(1, ["COMMAND"], "Running command '%s'." % [command])
	var lextree : CommandLexer.LexTreeNode = CommandLexer.tokenize_input(command)

	var most_recent_callback_holder : ArgumentNode = null
	var tag_map : Dictionary = {} #[StringName, CommandLexer.Token] 
	var working_tokennode : CommandLexer.LexTreeNode = lextree
	CommandTerminalLogger.log(3, ["COMMAND"], "Navigating lextree for callback and tagged args.")
	while true:
		if working_tokennode.token is CommandLexer.CommandToken: 
			var arg_node : ArgumentNode = working_tokennode.token.node
			if not working_tokennode.token.node.callback.is_null():
				CommandTerminalLogger.log(3, ["COMMAND"], "Found arg '%s' with callback '%s'." % [arg_node.argument, arg_node.callback])
				most_recent_callback_holder = arg_node
			if working_tokennode.token.node.argument.tag != null:
				CommandTerminalLogger.log(3, ["COMMAND"], "Found arg '%s' with tag '%s'." % [working_tokennode.token.name, arg_node.argument.tag.name])
				tag_map[arg_node.argument.tag.name] = working_tokennode.token
		if working_tokennode.children.size() == 0: break
		working_tokennode = working_tokennode.children.front()

	if most_recent_callback_holder == null:
		CommandTerminalLogger.log(3, ["COMMAND"], "No callback found. Command is invalid.")
		return

	CommandTerminalLogger.log(3, ["COMMAND"], "Handling callback arguments.")
	var callback : Callable = most_recent_callback_holder.callback
	var callback_arguments : Array[Variant] = []
	if most_recent_callback_holder.callback_arguments.size() > 0:
		CommandTerminalLogger.log(3, ["COMMAND"], "Parsing callback arguments...")
		for argument : Variant in most_recent_callback_holder.callback_arguments:
			if tag_map.has(argument):
				var tag_token : CommandLexer.Token = tag_map[argument]
				var tag : ArgumentTag = tag_token.node.argument.tag
				if tag.type == "String":
					callback_arguments.append(tag_token.content)
				elif tag.type == "StringName":
					callback_arguments.append(StringName(tag_token.content))
				else:
					var parser : Callable = tag.parser

					if parser.is_null():
						if parsers.has(tag.type):
							parser = parsers[tag.type]
						else:
							CommandTerminalLogger.log(3, ["COMMAND"], "ERROR: Tag '%s' includes no parser, and none is registered to CommandServer. Null provided." % [tag.name])
							callback_arguments.append(null)
							continue

					if parser.get_argument_count() != 1:
						CommandTerminalLogger.log(3, ["COMMAND"], "ERROR: Parser for tag '%s' of type '%s' is invalid, accepting %s arguments when 1 is expected. Null provided." % [tag.name, tag.type, parser.get_argument_count()])
						callback_arguments.append(null)
						continue

					var parsed_value : Variant = parser.call(tag_token.content)
					callback_arguments.append(parsed_value)
			else:
				CommandTerminalLogger.log(3, ["COMMAND"], "Callback argument '%s' not in tag map. Supplying argument itself." % [argument])
				callback_arguments.append(argument)
	else:
		CommandTerminalLogger.log(3, ["COMMAND"], "No callback arguments requested.")
	
	CommandTerminalLogger.log(2, ["COMMAND"], "Executing command...")
	callback.callv(callback_arguments)

var current_command : String = ""
#var relevant_arg : String = ""

var errors : Array[CommandError]
## Pushes an error to the CommandServer. Takes a string as input.
func push_error(error_message : String)	-> void:
	_push_errorfull("", "", error_message)

func _push_errorfull(attempted_command : String, relevant_arg : String, error_message : String) -> void:
	errors.append(CommandError.new(attempted_command, relevant_arg, error_message))
