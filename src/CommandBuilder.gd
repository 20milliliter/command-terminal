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
func Literal(_literal : StringName) -> CommandBuilder:
	self.add(ArgumentNode.new(LiteralArgument.new(_literal, optional)))
	return self

## Adds a [KeyArgument] to the command.
func Key(_name : String, _autofill_provider : Callable) -> CommandBuilder:
	self.add(ArgumentNode.new(KeyArgument.new(_name, optional, _autofill_provider)))
	return self

## Adds a [ValidatedArgument] to the command.
func Validated(_key : StringName, _validator : Callable = Callable(), _default : Variant = "") -> CommandBuilder:
	self.add(ArgumentNode.new(ValidatedArgument.new(_key, optional, _validator, _default)))
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
	branch_leaves_stack.append(upcoming_parents)
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

## Adds a callback to the command at the current position.[br]
## The callback is called when a command matching the structure it's a part of is submitted.[br]
## Multiple callbacks can be added to a single command at different positions if desired.
func Callback(_callback : Callable, _mapping : CallbackArgumentMapping = CallbackArgumentMapping.VOID) -> CommandBuilder:
	for node : ArgumentNode in upcoming_parents:
		node.callback = _callback
		node.callback_mapping = _mapping
	return self

## Signals that every following argument is optional.
func Optional() -> CommandBuilder:
	optional = true
	return self

## Returns the built ArgumentGraph.
## Doing anything with this except immediately giving it to [CommandServer.register_command] is not recommended.
func Build() -> ArgumentGraph:
	return root

func _build_deroot() -> ArgumentNode:
	return root.children[0]