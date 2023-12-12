class_name CommandTerminalLogger

const TAGS : Dictionary = {
	"TAG" : "[color=DIM_GRAY][COMMAND-TERMINAL][/color]",
	"PLUGIN" : "[color=DARK_GRAY][PLUGIN][/color]",
	"AUTOFILL" : "[color=DARK_GREEN][AUTOFILL][/color]",
	"TERMINAL" : "[color=GREEN][TERMINAL][/color]",
	"TOKENIZE" : "[color=WEBMAROON][TOKENIZE][/color]",
	"COMMAND" : "[color=RED][COMMAND][/color]",
	"PAINTING" : "[color=PURPLE][PAINTING][/color]",
}

static func log(message_level : int, tags : Array[String], message : String):
	var log_level = ProjectSettings.get_setting(CommandTerminalPluginData.PLUGIN_PATH + "logging_quantity", 5)
	if log_level < message_level: return

	var log_tag_mask = ProjectSettings.get_setting(CommandTerminalPluginData.PLUGIN_PATH + "logging_types", 127)
	for tag in tags:
		var tag_idx = TAGS.keys().find(tag)
		var bit_select = (log_tag_mask >> tag_idx) % 2
		var bit_check = bool(bit_select)
		if not bit_check: return

	print_rich(_build_tagchain(tags), " ", message)

static func _build_tagchain(tags : Array[String]) -> String:
	var out : PackedStringArray = []
	for tag in ["TAG"] + tags:
		out.append(TAGS[tag.to_upper()])
	return "".join(out)
