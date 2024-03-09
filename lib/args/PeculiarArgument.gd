class_name PeculiarArgument
extends Argument

func get_autofill_content() -> String: #virtual
	assert(false, "'get_autofill_content()' called on PeculiarArgument that does not implement it.")
	return ""