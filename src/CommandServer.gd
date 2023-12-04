#class_name CommandServer
extends Node

var argument_graph : ArgumentGraph = ArgumentGraph.new()

func register_command(_argument_graph : ArgumentGraph):
	CommandTerminalLogger.log(1, ["COMMAND"], "Registering command '%s'." % [_argument_graph.print_node_as_single()])
	#if ArgumentGraphValidator.is_valid_graph(_argument_graph)
	argument_graph.merge(_argument_graph)

var current_command : String
var current_arg : String

func _navigate_argument_graph(args : Array[String]) -> ArgumentNode:
	var graph_nav : ArgumentNode = argument_graph
	CommandTerminalLogger.log(3, ["COMMAND","NAVIGATION"], "Navigating with arguments '%s'" % [args]) 
	for arg in args:
		current_arg = arg
		CommandTerminalLogger.log(3, ["COMMAND","NAVIGATION"], "Navigating with target argument '%s'" % [arg]) 
		if len(graph_nav.children) == 0:
			CommandTerminalLogger.log(3, ["COMMAND","NAVIGATION"], "Command graph leaf reached. Proceeding...")
			break
		var valid_child_found : bool = false
		for node in graph_nav.children:
			if node.argument.is_valid(arg):
				CommandTerminalLogger.log(3, ["COMMAND","NAVIGATION"], "Found valid child: %s" % [node])
				graph_nav = node
				valid_child_found = true
				break
		if not valid_child_found:
			CommandTerminalLogger.log(3, ["COMMAND","NAVIGATION"], "No valid child found. Aborting.")
			return null
	return graph_nav

func get_autofill_candidates(current_text) -> Array[Argument]:
	CommandTerminalLogger.log(3, ["COMMAND", "AUTOFILL"], "Attempting autofill...")
	var args = current_text.split(" ")
	var complete_args = args.slice(0, -1)
	var incomplete_arg = args[-1]
	CommandTerminalLogger.log(3, ["COMMAND", "AUTOFILL"], "From position '%s'..." % [complete_args])
	var current_node : ArgumentNode = _navigate_argument_graph(complete_args)
	if current_node == null: 
		CommandTerminalLogger.log(3, ["COMMAND", "AUTOFILL"], "No candidates found.")
		return []
	CommandTerminalLogger.log(3, ["COMMAND", "AUTOFILL"], "Using text '%s'..." % [ incomplete_arg])
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
	current_command = command
	var args = command.split(" ", false)
	CommandTerminalLogger.log(1, ["COMMAND"], "Running command '%s'" % [args])
	var graph_nav : ArgumentNode = _navigate_argument_graph(args)
	if graph_nav == null: return
	CommandTerminalLogger.log(3, ["COMMAND"], "Locating callable.")
	var callback = _navigate_to_most_recent_callback(graph_nav)
	if callback.is_null(): return
	CommandTerminalLogger.log(2, ["COMMAND"], "Executing command...")
	callback.call(args)

var errors : Array[CommandError]

func push_error(error : String):
	errors.append(CommandError.new(current_command, current_arg, error))
