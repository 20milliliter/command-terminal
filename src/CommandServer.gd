#class_name CommandServer
extends Node

var argument_graph : ArgumentGraph = ArgumentGraph.new()

func register_command(_argument_graph : ArgumentGraph):
	print("[COMMAND TERMINAL] Attempting command registration")
	#if ArgumentGraphValidator.is_valid_graph(_argument_graph)
	argument_graph.merge(_argument_graph)

var current_command : String
var current_arg : String

func run_command(command : String):
	current_command = command
	var args = command.split(" ", false)
	print("[COMMAND] Running command '%s'" % [args])
	var graph_nav : ArgumentNode = argument_graph
	print("[COMMAND TERMINAL] Navigating with arguments '%s'" % [args])
	for arg in args:
		current_arg = arg
		print("[COMMAND TERMINAL][NAVIGATION] Navigating with target argument '%s'" % [arg])
		if len(graph_nav.children) == 0:
			print("[COMMAND TERMINAL][NAVIGATION] Command graph leaf reached. Proceeding...")
			break
		var valid_child_found : bool = false
		for node in graph_nav.children:
			if node.argument.is_valid(arg):
				print("[COMMAND TERMINAL][NAVIGATION] Found valid child: %s" % [node])
				graph_nav = node
				valid_child_found = true
				break
		if not valid_child_found:
			print("[COMMAND TERMINAL][NAVIGATION] No valid child found. Aborting.")
			return
	return graph_nav

func _navigate_to_most_recent_callback(node : ArgumentNode) -> Callable:
	print("[COMMAND TERMINAL][NAVIGATION] Navigating to most recent callback.")
	while len(node.parents) > 0:
		if not node.callback.is_null():
			print("[COMMAND TERMINAL][NAVIGATION] Callback found.")
			return node.callback
		node = node.parents[0]
		print("[COMMAND TERMINAL][NAVIGATION] Navigating to parent '%s'" % [node] )
	print("[COMMAND TERMINAL][NAVIGATION] No callback found.")
	return Callable()

func get_autofill_candidates(current_text) -> Array[String]:
	var args = current_text.split(" ", false)
	var current_node : ArgumentNode = _navigate_argument_graph(args.slice(0, -1))
	var candidates : Array[String] = []
	for child in current_node.children:
		if child.argument.is_autofill_candidate(args[-1]):
			candidates.append(child.argument.get_autofill_entry())
	return candidates

func run_command(command : String):
	current_command = command
	var args = command.split(" ", false)
	print("[COMMAND TERMINAL] Running command '%s'" % [args])
	var graph_nav : ArgumentNode = _navigate_argument_graph(args)
	print("[COMMAND TERMINAL] Locating callable.")
	var callback = _navigate_to_most_recent_callback(graph_nav)
	if callback.is_null():
		print("[COMMAND TERMINAL] No callback found. Aborting.")
	else:
		print("[COMMAND TERMINAL] Executing command...")
		callback.call(args)

var errors : Array[CommandError]

func push_error(error : String):
	errors.append(CommandError.new(current_command, current_arg, error))
