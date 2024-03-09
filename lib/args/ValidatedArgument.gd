class_name ValidatedArgument
extends PeculiarArgument

var name : StringName
var validator : Callable
var default_value: String

func _init(_name : StringName, _optional = false, _validator : Callable = Callable(), _default_value : Variant = ""):
	name = _name
	validator = _validator
	default_value = str(_default_value)
	super(_optional)

func _to_string() -> String:
	return "<%s>" % [name]

func _is_valid() -> bool:
	var validator_output = validator.call()
	if not validator_output is bool: return false
	return true

func _is_equal(argument : Argument) -> bool:
	if not argument is ValidatedArgument: return false
	if not name == argument.name: return false
	if not validator == argument.validator: return false
	return true

func get_autofill_content() -> String:
	return default_value

func get_autofill_entries(_remaining_input : String) -> Array[String]:
	if _remaining_input.find(" "):
		return [str(self)]
	return []

func get_satisfying_prefix(_remaining_input : String) -> String:
	var next : String = _remaining_input.get_slice(" ", 0)
	var next_is_valid : bool = validator.call(next)
	if next_is_valid:
		return next
	return ""