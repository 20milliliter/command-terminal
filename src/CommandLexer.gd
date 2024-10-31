class_name CommandLexer
extends RefCounted

static func tokenize_input(input : String) -> LexTreeNode:
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Preparing to tokenize.")
	var output : LexTreeNode = _tokenize(input)
	_clean_leftovers(output)
	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Returning tokenization: \n" + _print_tree(output))
	return output

static func _tokenize(
		_input : String, 
		_working_node : ArgumentNode = CommandServer.argument_graph,
		_colored_arg_count : int = 0
	) -> LexTreeNode:
	
	if _working_node is ArgumentGraph:
		# Working node is root, skip to children
		var dummynode : LexTreeNode = LexTreeNode.new(RootToken.new())
		if _working_node.children.size() == 0:
			dummynode.children.push_back(LexTreeNode.new(LeftoverToken.new(_input)))
		for child : ArgumentNode in _working_node.children:
			var child_node : LexTreeNode = _tokenize(_input, child)
			if (not child_node.token is LeftoverToken) or dummynode.children.size() == 0:
				dummynode.children.push_back(child_node)
			else:
				CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "LeftoverToken pruned.") 
		return dummynode

	CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], 
		"Trying '%s' against %s" % [_input, _working_node]
	)
	
	var argument : Argument = _working_node.argument
	var token : CommandToken = CommandToken.new(
		str(_working_node.argument),
		_working_node.argument,
		_working_node,
		Color.WHITE,
		_input
	)

	var treenode : LexTreeNode = LexTreeNode.new(token)
	var satisfying_prefix : String = argument.get_satisfying_prefix(_input)
	var trimmed_input : String = _input
	
	if satisfying_prefix != "":
		CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "'%s' accepted." % [satisfying_prefix])
		trimmed_input = _input.substr(satisfying_prefix.length())
		token.content = satisfying_prefix
		if _working_node.argument is ValidatedArgument or _working_node.argument is KeyArgument:
			_colored_arg_count += 1
			token.color = _COLORED_ARGS_COLOR_LIST[_colored_arg_count % _COLORED_ARGS_COLOR_LIST.size()]

		if trimmed_input.length() > 0:
			for child : ArgumentNode in _working_node.children:
				var child_node : LexTreeNode = _tokenize(trimmed_input.substr(1), child, _colored_arg_count)
				if (not child_node.token is LeftoverToken) or treenode.children.size() == 0:
					treenode.children.push_back(child_node)
			if _working_node.children.size() == 0:
				treenode.children.push_back(LexTreeNode.new(LeftoverToken.new(trimmed_input.substr(1))))

	if satisfying_prefix == "" or trimmed_input == "":
		var autocomplete_candidates : Array[String] = argument.get_autocomplete_entries(_input)
		if autocomplete_candidates.size() > 0:
			CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Accepted as autocomplete possibility.")
			token.provided_autocomplete_entries = autocomplete_candidates
			return LexTreeNode.new(token)
		if trimmed_input != "":
			CommandTerminalLogger.log(3, ["COMMAND","TOKENIZE"], "Not accepted.")  
			treenode.token = LeftoverToken.new(_input)

	

	return treenode

const _COLORED_ARGS_COLOR_LIST : Array[String] = [
	"#5FFAF8",
	"#F7FB68",
	"#56F75A",
	"#EC57E8",
	"#EDAA13",
]

static func _clean_leftovers(node : LexTreeNode) -> void:
	if node.children.size() > 1:
		for child : LexTreeNode in node.children.duplicate():
			if child.token is LeftoverToken:
				node.children.erase(child)
	for child :LexTreeNode in node.children:
		_clean_leftovers(child)

static func _print_tree(node : LexTreeNode, depth : int = 0) -> String:
	var content : String
	if node == null:
		return "null"
	if node.token != null:
		content = str(node.token)
	else:
		content = "root"
	content = "\t".repeat(depth) + content
	for child : LexTreeNode in node.children:
		if child != null:
			content += "\n" + _print_tree(child, depth + 1)
	return content

class Token extends RefCounted:
	var content : String
	var color : Color

	func get_color_as_hex() -> String:
		return "#%02X%02X%02X" % [color.r * 255, color.g * 255, color.b * 255]
	
class RootToken extends Token:
	func _to_string() -> String:
		return "root"

class LeftoverToken extends Token:
	func _init(_content : String) -> void:
		content = _content
		color = Color.RED

	func _to_string() -> String:
		return "LeftoverToken(\"%s\")" % content

class CommandToken extends Token:
	var name : String
	var argument : Argument
	var node : ArgumentNode
	var provided_autocomplete_entries : Array[String]

	func _init(
			_name : String, 
			_argument : Argument, 
			_node : ArgumentNode, 
			_color : Color, 
			_content : String, 
			_provided_autocomplete_entries : Array[String] = []
		) -> void:
		name = _name
		argument = _argument
		node = _node
		color = _color
		content = _content
		provided_autocomplete_entries = _provided_autocomplete_entries

	func _to_string() -> String:
		return "CommandToken(%s, %s, <%s>, \"%s\", %s)" % [name, argument, get_color_as_hex(), content, provided_autocomplete_entries]

class LexTreeNode extends RefCounted:
	var token : Token
	var children : Array[LexTreeNode]

	func _init(_token : Token, _children : Array[LexTreeNode] = []) -> void:
		token = _token
		children = _children

	func _to_string() -> String:
		return "LexTreeNode(%s, %s)" % [token, children]
