class_name ArgumentGraphValidator
extends RefCounted

static func is_valid_graph(graph : ArgumentGraph) -> bool:
	if not LiteralsValidator.validate_graph(graph): return false
	if not KeysValidator.validate_graph(graph): return false
	if not ValidatedsValidator.validate_graph(graph): return false
	if not VariadicsValidator.validate_graph(graph): return false
	return true

class LiteralsValidator extends RefCounted:

	static func validate_graph(graph : ArgumentGraph) -> bool:
		if not no_dupe_literals(graph): return false
		return true

	static func no_dupe_literals(graph : ArgumentGraph) -> bool:
		var literal_sibling_pairs = _filter_sibling_pairs(_get_literals(graph))
		for pair in literal_sibling_pairs:
			if pair[0].is_equal(pair[1]):
				print("Error: Duplicate literal found: ", pair[0].argument)
				return false
		return true
			
	static func _get_literals(node : ArgumentNode) -> Array[ArgumentNode]:
		var literals = [node] if node.argument is LiteralArgument else []
		for child in node.children:
			literals.append_array(_get_literals(child))
		return literals

	static func _filter_sibling_pairs(literals : Array[ArgumentNode]) -> Array[Array]:
		var literal_sibling_pairs = []
		for literal in literals:
			for sibling in literals:
				if literal == sibling: continue
				for parent in literal.parents:
					if sibling in parent.children:
						literal_sibling_pairs.append([literal, sibling])
		return literal_sibling_pairs

class KeysValidator extends RefCounted:
	static func validate_graph(graph : ArgumentGraph) -> bool:
		if not no_key_siblings(graph): return false
		return true

	static func no_key_siblings(graph : ArgumentGraph) -> bool:
		var key_sibling_pairs = _filter_sibling_pairs(_get_keys(graph))
		if key_sibling_pairs.size() > 0:
			print("Error: Keys cannot be siblings: ", key_sibling_pairs)
			return false
		return true
		
	static func _get_keys(node : ArgumentNode) -> Array[ArgumentNode]:
		var keys = [node] if node.argument is KeyArgument else []
		for child in node.children:
			keys.append_array(_get_keys(child))
		return keys

	static func _filter_sibling_pairs(keys : Array[ArgumentNode]) -> Array[Array]:
		var key_sibling_pairs = []
		for key in keys:
			for sibling in keys:
				if key == sibling: continue
				for parent in key.parents:
					if sibling in parent.children:
						key_sibling_pairs.append([key, sibling])
		return key_sibling_pairs

class ValidatedsValidator extends RefCounted:
	static func validate_graph(graph : ArgumentGraph) -> bool:
		#if not _no_validated_siblings(graph): return false
		return true

class VariadicsValidator extends RefCounted:
	static func validate_graph(graph : ArgumentGraph) -> bool:
		#if not _no_variadic_siblings(graph): return false
		return true