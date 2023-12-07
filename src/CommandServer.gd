#class_name CommandServer
extends Node

var tokenizer = preload("res://addons/command-terminal/src/CommandTokenizer.gd").new()
var argument_graph : ArgumentGraph = ArgumentGraph.new()

func register_command(_argument_graph : ArgumentGraph):
	CommandTerminalLogger.log(1, ["COMMAND"], "Registering command '%s'." % [_argument_graph.print_node_as_single()])
	#if ArgumentGraphValidator.is_valid_graph(_argument_graph)
	argument_graph.merge(_argument_graph)

func get_autofill_candidates(current_text) -> Array[Argument]:
	CommandTerminalLogger.log(3, ["COMMAND", "AUTOFILL"], "Attempting autofill...")
	var args = current_text.split(" ")
	var complete_args = args.slice(0, -1) if args.size() > 1 else []
	var incomplete_arg = args[-1]
	CommandTerminalLogger.log(3, ["COMMAND", "AUTOFILL"], "From position '%s'..." % [complete_args])
	var current_node : ArgumentNode = argument_graph
	if not complete_args.is_empty(): current_node = tokenizer.tokenize(complete_args).back().node
	if current_node == null: 
		CommandTerminalLogger.log(3, ["COMMAND", "AUTOFILL"], "No candidates found.")
		return []
	CommandTerminalLogger.log(3, ["COMMAND", "AUTOFILL"], "Using text '%s'..." % [incomplete_arg])
	var candidates : Array[Argument] = []
	for child in current_node.children:
		if child.argument.is_autofill_candidate(incomplete_arg):
			candidates.append(child.argument)
	CommandTerminalLogger.log(3, ["COMMAND", "AUTOFILL"], "Found candidates: %s." % [candidates])
	return candidates

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
	var graph_nav : ArgumentNode = tokenizer.tokenize(args).back().node
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
