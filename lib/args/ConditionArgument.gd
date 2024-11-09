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
	return CommandLexer.LexPrefix.new(condition.evaluate(), "")

class Evaluatable extends RefCounted:
	var evaluator : Callable

	func _init(_evaluator : Callable) -> void:
		evaluator = _evaluator

	func _to_string() -> String:
		return "%s" % [evaluator.get_method()]

	func evaluate() -> bool:
		return evaluator.call()