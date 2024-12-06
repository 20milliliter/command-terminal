class_name ConditionArgument
extends Argument
## A argument whose validity is determined by a Condition.
##
## A ConditionArgument is an argument whose validity is determined by a condition function.
var condition : Evaluatable

func _init(_condition : Evaluatable, _optional : bool = false) -> void:
	condition = _condition
	super(_optional)

func _to_string() -> String:
	return "{%s}" % [condition]

func _is_valid() -> bool:
	return condition != null

func _is_equal(argument : Argument) -> bool:
	if not argument is ConditionArgument: return false
	return argument.condition == condition

func get_autocomplete_entries(_remaining_input : String) -> Array[String]:
	return []

func get_satisfying_prefix(_remaining_input : String) -> CommandLexer.LexPrefix:
	return CommandLexer.LexPrefix.new(condition.evaluate(_tag_map), "")

var _tag_map : Dictionary = {} #[Variant, CommandLexer.Token]
func update_arguments(_new_argument_map : Dictionary) -> void:
	_tag_map = _new_argument_map

class Evaluatable extends RefCounted:
	var evaluator : Callable
	var arguments : Array[Variant]

	func _init(_evaluator : Callable, _arguments : Array[Variant]) -> void:
		evaluator = _evaluator
		arguments = _arguments

	func _to_string() -> String:
		return "{%s}" % [evaluator.get_method()]

	func _evaluated_or_err(mapped_arguments : Array[Variant]) -> Variant:
		if evaluator.is_null():
			push_error("Malformed evaluator for ConditionArgument Evaluatable%s, does not exist." % [self])
			return ERR_DOES_NOT_EXIST
		var result : Variant = evaluator.callv(mapped_arguments)
		if not result is bool:
			push_error("Malformed evaluator for ConditionArgument Evaluatable%s, does not return a bool." % [self])
			return ERR_INVALID_DATA
		return result

	func evaluate(_argument_map : Dictionary) -> bool:
		var mapped_arguments : Array[Variant] = arguments.map(
			func(arg : Variant) -> Variant:
				return CommandServer._parse_argument_against_tagmap(arg, _argument_map)
		)
		var result : Variant = _evaluated_or_err(mapped_arguments)
		if result is Error: return false
		return result
			