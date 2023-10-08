class_name ArgumentGraph
extends ArgumentNode

func _init(child : ArgumentNode = null):
	if not child == null:
		children.append(child)
	super(null, Callable())

func merge(source_tree : ArgumentGraph):
	print("\n\n\nMerging.")
	print("Target:")
	self.print_node()
	print("Source:")
	source_tree.print_node()
	merge_node(source_tree)
	print("Result:")
	self.print_node()

func merge_node(source_node: ArgumentNode, target_node = self):
	for source_child in source_node.children:
		var reparent : bool = true
		for target_child in target_node.children:
			if source_child.is_equal(target_child):
				merge_node(source_child, target_child)
				reparent = false
		if reparent:
			source_child.reparent([target_node])

func print_node(node : ArgumentNode = self, tabcount = 0):
	var tabs = ""
	for i in range(0, tabcount): tabs += "\t"

	var callback = node.callback
	if callback:
		print(tabs + "%s - %s" % [node.argument, callback])
	else:
		print(tabs + "%s" % [node.argument])

	for child in node.children:
		print_node(child, tabcount + 1)
