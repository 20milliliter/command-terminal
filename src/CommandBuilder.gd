class_name CommandBuilder
extends RefCounted

var logger = CommandTerminalLogger

var root : ArgumentGraph = ArgumentGraph.new()
var optional : bool = false

var upcoming_parents : Array[ArgumentNode] = [root]
var branch_stack : Array[Array] = []
var branch_leaves_stack : Array[Array] = []

func _init():
	logger.log(3, ["COMMAND", "BUILDER"], "New builder created.")

func add(node : ArgumentNode):
	logger.log(3, ["COMMAND", "BUILDER"], "Node added: %s" % [node])
	node.reparent(upcoming_parents)
	upcoming_parents = [node]

func Literal(_literal : StringName) -> CommandBuilder:
	self.add(ArgumentNode.new(LiteralArgument.new(_literal, optional)))
	return self

func Variadic() -> CommandBuilder:
	self.add(ArgumentNode.new(VariadicArgument.new()))
	return self

func Validated(_key : StringName, _validator : Callable = Callable()) -> CommandBuilder:
	self.add(ArgumentNode.new(ValidatedArgument.new(_key, optional, _validator)))
	return self
	
func Key(_name : String, _autofill_provider : Callable, _validator : Callable = Callable()) -> CommandBuilder:
	if _validator.is_null():
		_validator = func(a): 
			if a == "": return false
			for i in _autofill_provider.call():
				if i.begins_with(a):
					return true
			return false
	self.add(ArgumentNode.new(KeyArgument.new(_name, optional, _validator, _autofill_provider)))
	return self

func Branch() -> CommandBuilder:
	logger.log(2, ["COMMAND", "BUILDER"], "Branching...")
	branch_stack.push_back(upcoming_parents)
	logger.log(3, ["COMMAND", "BUILDER"], "Updated Branch stack: %s" % [branch_stack])
	return self

func NextBranch() -> CommandBuilder:
	logger.log(2, ["COMMAND", "BUILDER"], "Next branch...")
	branch_leaves_stack.append(upcoming_parents)
	upcoming_parents = branch_stack.back()
	logger.log(3, ["COMMAND", "BUILDER"], "Updated BranchLeaves stack: %s" % [branch_leaves_stack.back()])
	return self

func EndBranch() -> CommandBuilder:
	logger.log(2, ["COMMAND", "BUILDER"], "Ended current branch.")
	var old_parents = branch_leaves_stack.pop_back()
	if old_parents == null:
		push_error("CommandBuilder Error: Tried to end a branch without starting one.")
		return self
	upcoming_parents += old_parents
	branch_stack.pop_back()
	logger.log(3, ["COMMAND", "BUILDER"], "Recalled upcoming parents: %s" % [upcoming_parents])
	return self

func Callback(_callback : Callable) -> CommandBuilder:
	for node in upcoming_parents:
		node.callback = _callback
	return self

func Optional() -> CommandBuilder:
	optional = true
	return self

func Build() -> ArgumentGraph:
	return root

func _build_deroot() -> ArgumentNode:
	return root.children[0]
