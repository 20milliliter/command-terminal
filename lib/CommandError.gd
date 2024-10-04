class_name CommandError
extends RefCounted

var attempted_command : String
var argument : String
var error : String

func _init(_attempted_command : String, _argument : String, _error : String) -> void:
	attempted_command = _attempted_command
	argument = _argument
	error = _error