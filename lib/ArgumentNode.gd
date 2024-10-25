class_name ArgumentNode
extends RefCounted

var argument : Argument
var callback : Callable
var callback_arguments : Array

var parents :  Array[ArgumentNode]
var children : Array[ArgumentNode]

func _init(
		_argument : Argument, 
		_callback : Callable = Callable(), 
		_parents : Array[ArgumentNode] = [],
		_children : Array[ArgumentNode] = []
	) -> void:
	argument = _argument
	callback = _callback
	parents = _parents
	children = _children

func _to_string() -> String:
	if callback:
		return "ArgumentNode(%s, %s)" % [argument._to_string(), callback]
	else:
		return "ArgumentNode(%s)" % [argument._to_string()]

func is_equal(node : ArgumentNode) -> bool:
	return self.argument._is_equal(node.argument)

func add_child(node : ArgumentNode) -> void:
	self.children.append(node)
	node.parents.append(self)

func remove_child(node : ArgumentNode) -> void:
	self.children.erase(node)
	node.parents.erase(self)

func reparent(new_parents : Array[ArgumentNode] = []) -> void:
	for parent : ArgumentNode in parents.duplicate():
		parent.remove_child(self)
	for parent : ArgumentNode in new_parents:
		parent.add_child(self)
