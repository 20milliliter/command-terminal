class_name CommandToken
extends RefCounted

var name : String
var entry : String
var argument : Argument
var node : ArgumentNode
var color : Color
var is_valid : bool

func _init(_name : String, _entry : String, _argument : Argument, _node : ArgumentNode, _color : Color, _is_valid : bool):
	name = _name
	entry = _entry
	argument = _argument
	node = _node
	color = _color
	is_valid = _is_valid

func _to_string():
	return "CommandToken(%s, %s, %s, %s, %s, %s)" % [name, entry, argument, node, color, is_valid]

func get_color_as_hex() -> String:
	return "#%X%X%S" % [color.r * 255, color.g * 255, color.b * 255]