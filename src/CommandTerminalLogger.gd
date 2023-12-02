class_name CommandTerminalLogger

const TAGS : Dictionary = {
	"TAG" : "[color=DIM_GRAY][COMMAND-TERMINAL][/color]",
	"PLUGIN" : "[color=DARK_GRAY][PLUGIN][/color]",
	"AUTOFILL" : "[color=LIME][AUTOFILL][/color]",
	"TERMINAL" : "[color=GREEN][TERMINAL][/color]",
	"NAVIGATION" : "[color=WEBMAROON][NAVIGATION][/color]",
	"COMMAND" : "[color=RED][COMMAND][/color]",
}

static func log(level : int, tags : Array[String], message : String):
	if ProjectSettings.get_setting(CommandTerminalPluginData.PLUGIN_PATH + "/logging_quantity", 0) < level: return
	print_rich(_build_tagchain(tags), " ", message)

static func _build_tagchain(tags : Array[String]) -> String:
	var out : PackedStringArray = []
	for tag in ["TAG"] + tags:
		out.append(TAGS[tag.to_upper()])
	return "".join(out)