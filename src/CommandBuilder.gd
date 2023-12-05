class_name CommandBuilder
extends RefCounted

var root : ArgumentGraph = ArgumentGraph.new()
var optional : bool = false

var upcoming_parents : Array[ArgumentNode] = [root]

var writing_branches : bool = false
var branch_stack : Array[Array]
var writing_group : bool = false

func add(node : ArgumentNode):
	if writing_group:
		upcoming_parents[0].argument.arguments.push_back(node.argument)
		return
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

func Branch() -> CommandBuilder:
	if not writing_branches:
		writing_branches = true
		_start_branch()
	else:
		_next_branch()
	return self

func _start_branch():
	branch_stack.push_back(upcoming_parents)

func _next_branch():
	upcoming_parents = branch_stack.back()
	
func EndBranch() -> CommandBuilder:
	writing_branches = false
	branch_stack.pop_back()
	return self

func Group(_key : StringName, _validator : Callable = Callable()) -> CommandBuilder:
	self.add(ArgumentNode.new(GroupArgument.new(_key, [], optional, _validator)))
	writing_group = true
	return self

func EndGroup() -> CommandBuilder:
	writing_group = false
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
