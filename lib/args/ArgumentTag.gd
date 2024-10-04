class_name ArgumentTag
extends RefCounted

var name : StringName
var type : StringName
var parser : Callable

func _init(_name : StringName, _type : StringName, _parser : Callable = Callable()) -> void:
	name = _name
	type = _type
	parser = _parser