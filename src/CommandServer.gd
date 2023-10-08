#class_name CommandServer
extends Node

var argument_graph : ArgumentGraph = ArgumentGraph.new()

func register_command(_argument_graph : ArgumentGraph):
	print("[COMMAND] Attempting command registration")
	#if ArgumentGraphValidator.is_valid_graph(_argument_graph)
	argument_graph.merge(_argument_graph)

var current_command : String
var current_arg : String

func run_command(command : String):
	current_command = command
	var args = command.split(" ", false)
	print("[COMMAND] Running command '%s'" % [args])
	var graph_nav : ArgumentNode = argument_graph
	for arg in args:
		current_arg = arg
		print("[COMMAND_NAV] Navigating with target argument '%s'" % [arg])
		if len(graph_nav.children) == 0:
			print("[COMMAND_NAV] Command graph leaf reached. Proceeding...")
			break
		var valid_child_found : bool = false
		for node in graph_nav.children:
			if node.argument.is_valid(arg):
				print("[COMMAND_NAV] Found valid child: %s" % [node])
				graph_nav = node
				valid_child_found = true
				break
		if not valid_child_found:
			print("[COMMAND_NAV] No valid child found. Aborting.")
			return
	print("[COMMAND] Locating callable.")
	while len(graph_nav.parents) > 0:
		if not graph_nav.callback.is_null():
			print("[COMMAND_NAV] Callback found. Executing command...")
			graph_nav.callback.call(args)
			return
		print("[COMMAND_NAV] Navigating to parent.")
		graph_nav = graph_nav.parents[0]
	print("[COMMAND] No callback found. Aborting.")
	return

var errors : Array[CommandError]

func push_error(error : String):
	errors.append(CommandError.new(current_command, current_arg, error))
