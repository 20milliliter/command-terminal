class_name CommandPainter
extends RefCounted

# func paint_terminal_text(text : String):
# 	var text_args : Array[String] = text.split(" ")
# 	var chain : Array[ArgumentNode] = CommandServer.get_graphnode_chain(text_args)
# 	var args : Array[Argument] = []
# 	for node in chain:
# 		args.append(node.argument)
# 	var painted : String = ""
# 	for arg_idx in range(0, len(args)):
# 		var text_arg = text_args[arg_idx]
# 		var arg = args[arg_idx]
# 		painted += _paint_argument(text_arg, arg)
# 	return painted

# func _paint_argument(text : String, argument : Argument) -> String:
# 	if argument is ValidatedArgument:
# 		var color : String = _validated_argument_color_list[_validated_argument_color_index]
# 		return "[color=%s]%s[/color]" % [color, text]
# 	return text