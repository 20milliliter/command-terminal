class_name CallbackArgumentMapping
extends RefCounted

## Maps arguments from a full command to a be more concise.
## 
## CallbackArgumentMapping represents a desired mapping of arguments positioned in a full command to arguments positioned in a function signature.

## The mapping of arguments. For each index in the array, the value is the index of the argument in the full command to be mapped to that index.
var mapping : Array[int] 

static var VOID : CallbackArgumentMapping = CallbackArgumentMapping.new()

func _init(_mapping : Array[int] = []) -> void:
	mapping = _mapping

