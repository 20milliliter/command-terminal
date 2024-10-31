class_name CommandTerminalLogger

const TAGS : Dictionary = {
	"TAG" : "[color=gray][COMMAND-TERMINAL][/color]",
	"PLUGIN" : "[color=gray][PLUGIN][/color]",
	"AUTOCOMPLETE" : "[color=cyan][AUTOCOMPLETE][/color]",
	"TERMINAL" : "[color=green][TERMINAL][/color]",
	"TOKENIZE" : "[color=orange][TOKENIZE][/color]",
	"COMMAND" : "[color=red][COMMAND][/color]",
	"PAINTING" : "[color=purple][PAINTING][/color]",
	"BUILDER" : "[color=blue][BUILDER][/color]",
}

static func log(message_level : int, tags : Array[String], message : String) -> void:
	var log_level : int = ProjectSettings.get_setting(CommandTerminalPluginData.PLUGIN_PATH + "logging_quantity", 5)
	if log_level < message_level: return

	var log_tag_mask : int = ProjectSettings.get_setting(CommandTerminalPluginData.PLUGIN_PATH + "logging_types", 127)
	for tag : String in tags:
		var tag_idx : int = TAGS.keys().find(tag)
		var bit_select : int = (log_tag_mask >> tag_idx) % 2
		var bit_check : bool = bool(bit_select)
		if not bit_check: return

	print_rich(_build_tagchain(tags), " ", message)

static func _build_tagchain(tags : Array[String]) -> String:
	var out : Array[String] = []
	for tag : String in ["TAG"] + tags:
		out.append(TAGS[tag.to_upper()])
	return "".join(out)
	