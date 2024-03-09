class_name ArgumentGraph
extends ArgumentNode

func _to_string() -> String:
	return "ArgumentGraphRoot"

func _init(child : ArgumentNode = null) -> void:
	if not child == null:
		children.append(child)
	super(null, Callable())

func merge(source_tree : ArgumentGraph) -> void:
	CommandTerminalLogger.log(3, ["COMMAND"], "Executing an ArgumentGraph merge...")
	CommandTerminalLogger.log(3, ["COMMAND"], "Existing:\n" + self.print_node())
	CommandTerminalLogger.log(3, ["COMMAND"], "Source:\n" + source_tree.print_node_as_single())
	merge_node(source_tree)
	CommandTerminalLogger.log(3, ["COMMAND"], "Result:\n" + self.print_node())

func merge_node(source_node: ArgumentNode, target_node : ArgumentNode = self) -> void:
	for source_child : ArgumentNode in source_node.children:
		var needs_reparent : bool = true
		for target_child : ArgumentNode in target_node.children:
			if source_child.is_equal(target_child):
				merge_node(source_child, target_child)
				needs_reparent = false
		if needs_reparent:
			source_child.reparent([target_node])

func print_node_as_single() -> String:
	var args : Array[String] = []
	var node : ArgumentNode = self
	while len(node.children) != 0:
		node = node.children[0]
		args.append(node.argument.to_string())
	return " ".join(args)

func print_node(node : ArgumentNode = self, tabcount : int = 0) -> String:
	var out : String = ""
	var tabs : String = ""
	for i : int in range(0, tabcount): tabs += "\t"

	if node.argument == null:
		for child : ArgumentNode in node.children:
			out += "\n" + print_node(child, tabcount + 1)
		return out + "\n"

	var nodes_callback : Callable = node.callback
	if nodes_callback:
		out += tabs + "%s - %s" % [node.argument, nodes_callback]
	else:
		out += tabs + "%s" % [node.argument]

	for child : ArgumentNode in node.children:
		out += "\n" + print_node(child, tabcount + 1)
	
	return out
