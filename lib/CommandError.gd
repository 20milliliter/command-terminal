class_name CommandError
extends Object

var attempted_command : String
var argument : String
var error : String

func _init(_attempted_command : String, _argument : String, _error : String):
	attempted_command = _attempted_command
	argument = _argument
	error = _error