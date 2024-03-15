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

## Runs a command. Takes a string as input.
## The CommandTerminal control node handles running commands by itself, but this may be used if you want to run a command from elsewhere.
func run_command(command : String) -> void:
	var tokentree : CommandTokenizer.TokenTreeNode = CommandTokenizer.tokenize_input(command)
	var end : CommandTokenizer.TokenTreeNode = tokentree.children.back()
	while end.children.size() > 0:
		end = end.children.back()
	var graph_nav : ArgumentNode = end.token.node
	if graph_nav == null: return
	CommandTerminalLogger.log(3, ["COMMAND"], "Locating callable.")
	var callback_holder : ArgumentNode = _navigate_to_most_recent_callback_holder(graph_nav)
	if callback_holder == null: return
	var callback : Callable = callback_holder.callback
	CommandTerminalLogger.log(3, ["COMMAND"], "Mapping arguments...")
	var command_args : PackedStringArray = command.split(" ")
	var callback_args : Array[String] = []
	for arg_idx : int in callback_holder.callback_mapping.mapping:
		callback_args.append(command_args[arg_idx])
	CommandTerminalLogger.log(2, ["COMMAND"], "Executing command...")
	callback.callv(callback_args)

func _navigate_to_most_recent_callback_holder(node : ArgumentNode) -> ArgumentNode:
	CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "Navigating to most recent callback.")
	while len(node.parents) > 0:
		if not node.callback.is_null():
			CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "Callback found.")
			return node
		node = node.parents[0]
		CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "Navigating to parent '%s'" % [node])
	CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "No callback found.")
	return null

var current_command : String = ""
#var relevant_arg : String = ""

var errors : Array[CommandError]
## Pushes an error to the CommandServer. Takes a string as input.
func push_error(error_message : String)	-> void:
	_push_errorfull("", "", error_message)

func _push_errorfull(attempted_command : String, relevant_arg : String, error_message : String) -> void:
	errors.append(CommandError.new(attempted_command, relevant_arg, error_message))
