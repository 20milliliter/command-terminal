#class_name CommandPainter
extends RefCounted

func paint_terminal_text(text : String):
	var token_strings : Array[String] = []
	var tokens : Array = CommandServer.tokenizer.tokenize(text)
	print("Revcieved tokens: %s" % [tokens])
	for token in tokens:
		token_strings.append(_paint_token(token))
	print("Painted tokens: %s" % [token_strings])
	return " ".join(token_strings)
	
func _paint_token(token) -> String:
	var output : String = "[color=%s]%s[/color]" % [token.get_color_as_hex(), token.entry]
	print(output.replace("[", "[lb]"))
	return output