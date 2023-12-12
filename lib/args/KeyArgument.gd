class_name KeyArgument
extends Argument

var name : StringName
var validator : Callable
var autofill_provider : Callable

func _init(_name : StringName, _optional = false, _validator : Callable = Callable(), _autofill_provider : Callable = Callable()):
	name = _name
	validator = _validator
	autofill_provider = _autofill_provider
	super(_optional)

func _to_string() -> String:
	return "<%s>" % [name]

func get_autofill_entries() -> Array[String]:
	return autofill_provider.call()

func is_equal(argument : Argument):
	if not argument is KeyArgument: return false
	return argument.key == self.key and argument.validator == self.validator and argument.autofill_provider == self.autofill_provider
	
func is_valid(_input : String) -> bool: 
	return validator.call(_input)
