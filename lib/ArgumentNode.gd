class_name ArgumentNode
extends Object

var argument : Argument

var parents :  Array[ArgumentNode]
var children : Array[ArgumentNode]

func _init(_argument, _parents = null, _children = []):
	argument = _argument
	parents = _parents
	children = _children

func is_equal(node : ArgumentNode) -> bool:
	return self.argument.is_equal(node.argument)

func add_child(node : ArgumentNode):
	self.children.append(node)
	node.parents.append(self)

func remove_child(node : ArgumentNode):
	self.children.erase(node)
	node.parents.erase(self)

func reparent(new_parents : Array[ArgumentNode]):
	for parent in parents.duplicate():
		parent.remove_child(self)
	for parent in new_parents:
		parent.add_child(self)