#class_name CommandServer
extends Node

var argument_graph : ArgumentGraph = ArgumentGraph.new()

func register_command(_argument_graph : ArgumentGraph) -> void:
	CommandTerminalLogger.log(1, ["COMMAND"], "Registering command '%s'." % [_argument_graph.print_node_as_single()])
	#if ArgumentGraphValidator.is_valid_graph(_argument_graph)
	argument_graph.merge(_argument_graph)

func run_command(command : String) -> void:
	var tokentree : CommandTokenizer.TokenTreeNode = CommandTokenizer.tokenize_input(command)
	var end : CommandTokenizer.TokenTreeNode = tokentree.children.back()
	while end.children.size() > 0:
		end = end.children.back()
	var graph_nav : ArgumentNode = end.token.node
	if graph_nav == null: return
	CommandTerminalLogger.log(3, ["COMMAND"], "Locating callable.")
	var callback : Callable = _navigate_to_most_recent_callback(graph_nav)
	if callback.is_null(): return
	CommandTerminalLogger.log(2, ["COMMAND"], "Executing command...")
	callback.call(command.split(" "))

func _navigate_to_most_recent_callback(node : ArgumentNode) -> Callable:
	CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "Navigating to most recent callback.")
	while len(node.parents) > 0:
		if not node.callback.is_null():
			CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "Callback found.")
			return node.callback
		node = node.parents[0]
		CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "Navigating to parent '%s'" % [node])
		CommandTerminalLogger.log(3, ["COMMAND", "NAVIGATION"], "No callback found.")
	return Callable()

var current_command : String = ""
#var relevant_arg : String = ""

var errors : Array[CommandError]
func push_error(error_message : String)	-> void:
	_push_errorfull("", "", error_message)

func _push_errorfull(attempted_command : String, relevant_arg : String, error_message : String) -> void:
	errors.append(CommandError.new(attempted_command, relevant_arg, error_message))
