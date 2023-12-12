#class_name CommandServer
extends Node

var tokenizer = preload("res://addons/command-terminal/src/CommandTokenizer.gd").new()
var argument_graph : ArgumentGraph = ArgumentGraph.new()

func register_command(_argument_graph : ArgumentGraph):
	CommandTerminalLogger.log(1, ["COMMAND"], "Registering command '%s'." % [_argument_graph.print_node_as_single()])
	#if ArgumentGraphValidator.is_valid_graph(_argument_graph)
	argument_graph.merge(_argument_graph)

func get_arg_info_from_text(text : String) -> Dictionary:
	var args = text.split(" ")
	return {
		"args" : args,
		"complete_args" : args.slice(0, -1) if args.size() > 1 else [],
		"incomplete_arg" : args[-1],
	}

func get_working_argumentnode(text : String) -> ArgumentNode:
	var tokens = CommandServer.tokenizer.tokenize_text(text)
	if not tokens.is_empty():
		while tokens.back().is_valid == false:
			tokens.pop_back()
			if tokens.is_empty(): return CommandServer.argument_graph
		return tokens.back().node
	return CommandServer.argument_graph

func _navigate_to_most_recent_callback(node : ArgumentNode) -> Callable:
	CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "Navigating to most recent callback.")
	while len(node.parents) > 0:
		if not node.callback.is_null():
			CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "Callback found.")
			return node.callback
		node = node.parents[0]
		CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "Navigating to parent '%s'" % [node] )
		CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "No callback found.")
	return Callable()

func run_command(command : String):
	var args = command.split(" ", false)
	CommandTerminalLogger.log(1, ["COMMAND"], "Running command '%s'" % [args])
	var tokens = self.tokenizer.tokenize_args(args)
	if tokens.is_empty(): return
	var graph_nav : ArgumentNode = tokens.back().node
	if graph_nav == null: return
	CommandTerminalLogger.log(3, ["COMMAND"], "Locating callable.")
	var callback = _navigate_to_most_recent_callback(graph_nav)
	if callback.is_null(): return
	CommandTerminalLogger.log(2, ["COMMAND"], "Executing command...")
	callback.call(args)

var current_command : String = ""
var relevant_arg : String = ""

var errors : Array[CommandError]
func push_error(error_message : String):
	_push_errorfull("", "", error_message)

func _push_errorfull(attempted_command : String, relevant_arg : String, error_message : String):
	errors.append(CommandError.new(attempted_command, relevant_arg, error_message))
