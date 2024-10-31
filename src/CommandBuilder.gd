class_name CommandBuilder
extends RefCounted
## A builder to make building commands not a pain.
##
## The CommandBuilder facilitiates the building of ArgumentGraphs, which is what constitutes a command.
## As a builder, it supports method chaining. [br][br]
## [b]Note:[/b] While the builder supports building complicated structures, the server supports registering multiple "versions" of a command, so creating a complex command in "chunks" is ideal for readability.

var root : ArgumentGraph = ArgumentGraph.new()
var optional : bool = false

var upcoming_parents : Array[ArgumentNode] = [root]
var branch_stack : Array[Array] = []
var branch_leaves_stack : Array[Array] = []

func _init() -> void:
	CommandTerminalLogger.log(3, ["COMMAND", "BUILDER"], "New builder created.")

func add(node : ArgumentNode) -> void:
	CommandTerminalLogger.log(3, ["COMMAND", "BUILDER"], "Node added: %s" % [node])
	node.reparent(upcoming_parents)
	upcoming_parents = [node]

## Adds a [LiteralArgument] to the command.
func Literal(literal : StringName) -> CommandBuilder:
	self.add(ArgumentNode.new(LiteralArgument.new(literal, optional)))
	return self

## Adds a [KeyArgument] to the command.
func Key(name : String, keys_provider : Callable) -> CommandBuilder:
	self.add(ArgumentNode.new(KeyArgument.new(name, keys_provider, optional)))
	return self

## Adds a [ValidatedArgument] to the command.
func Validated(key : StringName, validator : Callable, default : Variant = "") -> CommandBuilder:
	self.add(ArgumentNode.new(ValidatedArgument.new(key, validator, optional, default)))
	return self

## Adds a [VariadicArgument] to the command.
func Variadic() -> CommandBuilder:
	self.add(ArgumentNode.new(VariadicArgument.new()))
	return self

## Creates a branch.[br]
## A branch is a possible path that the command can take. 
## It is useful for creating commands with multiple versions or optional arguments.
func Branch() -> CommandBuilder:
	CommandTerminalLogger.log(2, ["COMMAND", "BUILDER"], "Branching...")
	branch_stack.push_back(upcoming_parents)
	CommandTerminalLogger.log(3, ["COMMAND", "BUILDER"], "Updated Branch stack: %s" % [branch_stack])
	return self

## Signals to create the next path of a branch. 
func NextBranch() -> CommandBuilder:
	CommandTerminalLogger.log(2, ["COMMAND", "BUILDER"], "Next branch...")
	var branch_leaves : Array[ArgumentNode] = []
	if branch_leaves_stack.size() > 0:
		branch_leaves = branch_leaves_stack.pop_back()
	branch_leaves.append_array(upcoming_parents)
	branch_leaves_stack.push_back(branch_leaves)
	upcoming_parents = branch_stack.back()
	CommandTerminalLogger.log(3, ["COMMAND", "BUILDER"], "Updated BranchLeaves stack: %s" % [branch_leaves_stack.back()])
	return self

## Signals to end the current branch. If any other arguments are added, they will follow the end of every branch. 
func EndBranch() -> CommandBuilder:
	CommandTerminalLogger.log(2, ["COMMAND", "BUILDER"], "Ended current branch.")
	var old_parents : Array[ArgumentNode] = branch_leaves_stack.pop_back()
	if old_parents == null:
		push_error("CommandBuilder Error: Tried to end a branch without starting one.")
		return self
	upcoming_parents += old_parents
	branch_stack.pop_back()
	CommandTerminalLogger.log(3, ["COMMAND", "BUILDER"], "Recalled upcoming parents: %s" % [upcoming_parents])
	return self

func _bad_tag_target() -> bool:
	if upcoming_parents.size() > 1: 
		CommandTerminalLogger.log(3, ["COMMAND", "BUILDER"], "WARNING: Cannot tag the end of a branch. Tag not applied.")
		return true
	elif upcoming_parents.is_empty():
		CommandTerminalLogger.log(3, ["COMMAND", "BUILDER"], "WARNING: Must tag an arg, not nothing. Tag not applied.")
		return true
	return false

## Tags the previous argument.
func Tag(name : StringName, type : StringName, parser : Callable = Callable()) -> CommandBuilder:
	if _bad_tag_target(): return self
	upcoming_parents[0].argument.tag = ArgumentTag.new(name, type, parser)
	return self

## Tags the previous argument, assuming the tag name as the argument's "given name".
func Tag_gn(type : StringName, parser : Callable = Callable()) -> CommandBuilder:
	if _bad_tag_target(): return self
	var arg : Argument = upcoming_parents[0].argument
	var tag_name : StringName = ""
	if arg is LiteralArgument:
		tag_name = arg.literal
	elif arg is KeyArgument:
		tag_name = arg.name
	elif arg is ValidatedArgument:
		tag_name = arg.name
	elif arg is VariadicArgument:
		tag_name = "..."
	arg.tag = ArgumentTag.new(tag_name, type, parser)
	return self

## Tags the previous argument, assuming the type to be "StringName".
func Tag_st(name : StringName, parser : Callable = pass_through) -> CommandBuilder:
	return Tag(name, "StringName", parser)

## Tags the previous argument, assuming the tag name as the argument's "given name", and assuming the type to be "StringName".
func Tag_gnst(parser : Callable = pass_through) -> CommandBuilder:
	return Tag_gn("StringName", parser)

func pass_through(v : Variant) -> Variant: return v

## Adds a callback to the command at the current position.[br]
## The callback is called when a command matching the structure it's a part of is submitted.[br]
## Multiple callbacks can be added to a single command at different positions if desired.
func Callback(callback : Callable, arguments : Array[Variant] = []) -> CommandBuilder:
	for node : ArgumentNode in upcoming_parents:
		node.callback = callback
		node.callback_arguments = arguments
	return self

## Signals that every following argument is optional.
func Optional() -> CommandBuilder:
	optional = true
	return self

## Returns the built ArgumentGraph.
## Doing anything with this except immediately giving it to [method CommandServer.register_command] is not recommended.
func Build() -> ArgumentGraph:
	return root

func _build_deroot() -> ArgumentNode:
	return root.children[0]