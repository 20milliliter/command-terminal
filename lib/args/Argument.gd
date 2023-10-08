class_name Argument
extends Object

var optional : bool

func _init(_optional = false):
	optional = _optional

func _to_string() -> String: #virtual
	assert(false)
	return ""

func is_equal(argument : Argument) -> bool: #virtual
	assert(false)
	return false
	
func is_valid(_input) -> bool: #virtual
	assert(false)
	return false

func is_autofill_candidate(_input) -> bool: #virtual
	assert(false)
	return false
