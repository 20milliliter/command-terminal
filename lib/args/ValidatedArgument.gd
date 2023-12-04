class_name ValidatedArgument
extends Argument

var key : StringName
var validator : Callable

func _init(_key : StringName, _optional = false, _validator : Callable = Callable()):
	key = _key
	validator = _validator
	super()

func _to_string() -> String:
	return "<%s>" % [key]

func get_autofill_entry() -> String:
	return "<%s>" % [key]

func get_autofill_result() -> String:
	return ""

func is_equal(argument : Argument):
	if not argument is ValidatedArgument: return false
	return argument.key == self.key and argument.validator == self.validator
	
func is_valid(_input) -> bool: 
	return validator.call(_input)

func is_autofill_candidate(_input) -> bool:
	if _input == "": return true
	return is_valid(_input)