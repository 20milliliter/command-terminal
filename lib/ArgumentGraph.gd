class_name ArgumentGraph
extends Object

var children : Array[ArgumentNode]

func _init(child : ArgumentNode):
	children.append(child)

func merge(source_tree : ArgumentGraph):
	for child in source_tree.children:
		merge_node(child)

func merge_node(source_node: ArgumentNode, target_node = self):
	for source_child in source_node.children:
		var reparent : bool = true
		for target_child in target_node.children:
			if source_child.is_equal(target_child):
				merge_node(source_child, target_child)
				reparent = false
		if reparent:
			source_child.reparent(target_node)