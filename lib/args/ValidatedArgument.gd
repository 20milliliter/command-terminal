class_name ValidatedArgument
extends PeculiarArgument
## An argument with a validator [Callable].
##
## A ValidatedArgument is an argument that is associated with a [Callable] to determine if a given input is valid.
## It's primary use-case is for numerical arguments.

## The name of the argument.
var name : StringName
## The [Callable] that determines if a given input is valid.
var validator : Callable
## The default value of the argument. If a ValidatedArgument is autocompleteed, it will use this value. Optional.
var default_value: String

func _init(
		_name : StringName, 
		_validator : Callable, 
		_optional : bool = false, 
		_default_value : Variant = ""
	) -> void:
	name = _name
	validator = _validator
	default_value = str(_default_value)
	super(_optional)

func _to_string() -> String:
	return "<%s>" % [name]

func _is_valid() -> bool:
	var validator_output : Variant = validator.call()
	if not validator_output is bool: return false
	return true

func _is_equal(argument : Argument) -> bool:
	if not argument is ValidatedArgument: return false
	if not name == argument.name: return false
	if not validator == argument.validator: return false
	return true

func get_autocomplete_content() -> String:
	return default_value

func get_autocomplete_entries(_remaining_input : String) -> Array[String]:
	if get_satisfying_prefix(_remaining_input) != "" or _remaining_input == "":
		return [str(self)]
	return []

func get_satisfying_prefix(_remaining_input : String) -> String:
	var next : String = _remaining_input.get_slice(" ", 0)
	var next_is_valid : bool = validator.call(next)
	if next_is_valid:
		return next
	return ""