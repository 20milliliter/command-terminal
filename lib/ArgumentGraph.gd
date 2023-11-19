class_name ArgumentGraph
extends ArgumentNode

func _to_string() -> String:
	return "ArgumentGraphRoot"

func _init(child : ArgumentNode = null):
	if not child == null:
		children.append(child)
	super(null, Callable())

func merge(source_tree : ArgumentGraph):
	CommandTerminalLogger.log(2, ["COMMAND"], "Executing an ArgumentGraph merge...")
	CommandTerminalLogger.log(3, ["COMMAND"], "Existing:\n" + self.print_node())
	CommandTerminalLogger.log(3, ["COMMAND"], "Source:\n" + source_tree.print_node_as_single())
	merge_node(source_tree)
	CommandTerminalLogger.log(2, ["COMMAND"], "Result:\n" + self.print_node())

func merge_node(source_node: ArgumentNode, target_node = self):
	for source_child in source_node.children:
		var reparent : bool = true
		for target_child in target_node.children:
			if source_child.is_equal(target_child):
				merge_node(source_child, target_child)
				reparent = false
		if reparent:
			source_child.reparent([target_node])

func print_node_as_single() -> String:
	var args : PackedStringArray = []
	var node = self
	while len(node.children) != 0:
		node = node.children[0]
		args.append(node.argument.to_string())
	return " ".join(args)

func print_node(node : ArgumentNode = self, tabcount = 0) -> String:
	var out = ""
	var tabs = ""
	for i in range(0, tabcount): tabs += "\t"

	if node.argument == null:
		for child in node.children:
			out += "\n" + print_node(child, tabcount + 1)
		return out + "\n"

	var callback = node.callback
	if callback:
		out += tabs + "%s - %s" % [node.argument, callback]
	else:
		out += tabs + "%s" % [node.argument]

	for child in node.children:
		out += "\n" + print_node(child, tabcount + 1)
	
	return out
