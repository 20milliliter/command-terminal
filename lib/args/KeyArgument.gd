class_name KeyArgument
extends Argument

## A KeyArgument is an argument that can be one of a set of String keys.
##
## A KeyArgument is an argument that can be one of a set of String keys.
## The set of possible keys is retrieved from a Callable, provided on initialization.
## [b]Note:[/b] The set of possible keys is not fixed, the Callable may provide any set/subset arbitrarily.

## The name of the argument.
var name : StringName
## The Callable that provides the set of possible keys.
var keys_provider : Callable

func _init(_name : StringName, _keys_provider : Callable, _optional : bool = false) -> void:
	name = _name
	keys_provider = _keys_provider
	super(_optional)

func _to_string() -> String:
	return "<%s>" % [name]

func _is_valid() -> bool:
	var keys_provider_output : Variant = keys_provider.call()
	if not keys_provider_output is Array[StringName]: return false
	return true

func _is_equal(argument : Argument) -> bool:
	if not argument is KeyArgument: return false
	if not argument.name == name: return false
	if not argument.keys_provider == keys_provider: return false
	return true
		
func get_autocomplete_entries(_remaining_input : String) -> Array[String]:
	var keys : Array[StringName] = []
	keys.assign(keys_provider.call())
	var candidate_keys : Array[String] = []
	for key : StringName in keys:
		if key.begins_with(_remaining_input):
			candidate_keys.append(key)
	return candidate_keys

func get_satisfying_prefix(_remaining_input : String) -> String:
	var keys : Array[StringName] = []
	keys.assign(keys_provider.call())
	for key : StringName in keys:
		if _remaining_input.begins_with(key + " "):
			return key
	return ""
