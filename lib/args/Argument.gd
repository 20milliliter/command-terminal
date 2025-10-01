@abstract class_name Argument
extends RefCounted
## The abstract base class for Argument types.
##
## The abstract base class for Argument types.

## Whether the argument is optional or not.
var optional : bool

## The argument's tag, if it has one.
var tag : ArgumentTag

@abstract func _to_string() -> String
@abstract func _is_valid() -> bool
@abstract func _is_equal(_argument : Argument) -> bool
@abstract func get_autocomplete_entries(_remaining_input : String) -> Array[String]
@abstract func get_satisfying_prefix(_remaining_input : String) -> CommandLexer.LexPrefix
