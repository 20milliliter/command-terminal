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

func _valid_or_err(value : String) -> Variant:
	if validator.is_null():
		push_error("Malformed validator for ValidatedArgument%s, does not exist." % [self])
		return ERR_DOES_NOT_EXIST
	var validator_output : Variant = validator.call(value)
	if not validator_output is bool: 
		push_error("Malformed validator for ValidatedArgument%s, does not return a bool." % [self])
		return ERR_INVALID_DATA
	return validator_output

func get_autocomplete_entries(_remaining_input : String) -> Array[String]:
	if get_satisfying_prefix(_remaining_input).content != "" or _remaining_input == "":
		return [str(self)]
	return []

func get_satisfying_prefix(_remaining_input : String) -> CommandLexer.LexPrefix:
	var next : String = _remaining_input.get_slice(" ", 0)
	var validator_output : Variant = _valid_or_err(next)
	if not validator_output is Error:
		var next_is_valid : bool = validator_output as bool
		if next_is_valid:
			return CommandLexer.LexPrefix.new(true, next)
	return CommandLexer.LexPrefix.new(false)