class_name ValidatedArgument
extends Argument

var name : StringName
var validator : Callable

func _init(_name : StringName, _optional = false, _validator : Callable = Callable()):
	name = _name
	validator = _validator
	super(_optional)

func _to_string() -> String:
	return "<%s>" % [name]

func get_autofill_result() -> String:
	return ""

func is_equal(argument : Argument):
	if not argument is ValidatedArgument: return false
	return argument.name == self.name and argument.validator == self.validator
	
func is_valid(_input : String) -> bool: 
	return validator.call(_input)

func is_autofill_candidate(_input) -> bool:
	if _input == "": return true
	return is_valid(_input)