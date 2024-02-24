class_name KeyArgument
extends Argument

var name : StringName
var validator : Callable
var keys_provider : Callable

func _init(_name : StringName, _optional = false, _validator : Callable = Callable(), _keys_provider : Callable = Callable()):
	name = _name
	validator = _validator
	keys_provider = _keys_provider
	super(_optional)

func _to_string() -> String:
	return "<%s>" % [name]

func _is_valid() -> bool:
	var validator_output = validator.call("")
	if not validator_output is bool: return false
	var keys_provider_output = keys_provider.call()
	if not keys_provider_output is Array[String]: return false
	return true

func _is_equal(argument : Argument):
	if not argument is KeyArgument: return false
	if not argument.name == name: return false
	if not argument.validator == validator: return false
	if not argument.keys_provider == keys_provider: return false
	return true
		
func get_autofill_entries(_remaining_input : String) -> Array[String]:
	var keys : Array[String] = keys_provider.call()
	var candidate_keys : Array[String] = []
	for key in keys:
		if key.begins_with(_remaining_input):
			candidate_keys.append(key)
	return candidate_keys

func get_satisfying_prefix(_remaining_input : String) -> String:
	var keys : Array[String] = keys_provider.call()
	for key in keys:
		if _remaining_input.begins_with(key + " "):
			return key
	return ""
