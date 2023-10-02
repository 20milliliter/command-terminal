class_name ValidatedArgument
extends Argument

var key : StringName
var validator : Callable

func _init(_key : StringName, _optional = false, _validator : Callable = Callable()):
	key = _key
	validator = _validator
	super()

func is_equal(argument : Argument):
	if not argument is ValidatedArgument: return false
	return argument.key == self.key and argument.validator == self.validator
	
func is_valid(_input) -> bool: 
	return validator.call(_input)

func is_autofill_candidate(_input) -> bool:
	return false