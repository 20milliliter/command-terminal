class_name CommandBuilder

var root : ArgumentNode = null
var optional : bool = false

var upcoming_parents : Array[ArgumentNode]

var writing_branches : bool = false
var branch_stack : Array[Array]

func add(node : ArgumentNode):
	if root == null:
		root = node
	else:
		node.reparent(upcoming_parents)
	upcoming_parents = [node]

func Literal(_literal : StringName) -> CommandBuilder:
	self.add(ArgumentNode.new(LiteralArgument.new(_literal, optional)))
	return self

func Variadic() -> CommandBuilder:
	self.add(ArgumentNode.new(VariadicArgument.new()))
	return self

func Key(_key : StringName, _validator : Callable = Callable()) -> CommandBuilder:
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

func Optional() -> CommandBuilder:
	optional = true
	return self

func Build() -> ArgumentGraph:
	return ArgumentGraph.new(root)

static func test():
	CommandServer.register_command(
		CommandBuilder.new().Literal("dmx").Literal("override").Literal("clear").Build()
	)
	CommandServer.register_command(
		CommandBuilder.new()
			.Literal("dmx")
			.Literal("override")
				.Branch().Literal("channel")
				.Branch().Literal("universe")
			.EndBranch()
				.Branch().Key("<index>")
				.Branch().Literal("range").Key("<start_index>").Key("<end_index>")
			.EndBranch()
				.Branch().Key("<value>")
				.Branch().Literal("pattern").Key("<pattern_name>").Variadic()
			.EndBranch()
		.Build()
	)