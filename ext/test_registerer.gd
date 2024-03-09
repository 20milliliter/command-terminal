extends Node

func _ready():
	CommandServer.register_command(
		CommandBuilder.new().Literal("dmx").Literal("devices").Literal("list").Callback(dmx_devices_list).Build()
	)
	CommandServer.register_command(
		CommandBuilder.new().Literal("dmx").Literal("override").Literal("clear").Callback(dmx_override_clear).Build()
	)
	CommandServer.register_command(
		CommandBuilder.new().Literal("dmx").Literal("devices").Key("device_name", get_dmx_devices_list).Literal("push").Variadic().Callback(dmx_devices_push).Build()
	)
	CommandServer.register_command(
		CommandBuilder.new().Literal("dmx").Literal("channel").Validated("channel_index", is_valid_channel_index).Literal("check").Callback(channel_check).Build()
	)
	CommandServer.register_command(
		CommandBuilder.new().Literal("dmx").Literal("override").Literal("channel")
			.Branch()
				.Validated("channel_index", is_valid_channel_index)
			.NextBranch()
				.Literal("range").Validated("start_channel_index", is_valid_channel_index).Validated("end_channel_index", is_valid_channel_index)
			.EndBranch()
			.Branch()
				.Validated("value", is_valid_dmx_value)
			.NextBranch()
				.Literal("pattern").Variadic()
			.EndBranch()
		.Build()
	)
	CommandServer.register_command(
		CommandBuilder.new().Literal("dmx").Literal("override").Literal("universe")
			.Branch()
				.Validated("universe_index", is_valid_universe_index)
			.NextBranch()
				.Literal("range").Validated("start_universe_index", is_valid_universe_index).Validated("end_universe_index", is_valid_universe_index)
			.EndBranch()
			.Branch()
				.Validated("value", is_valid_dmx_value)
			.NextBranch()
				.Literal("pattern").Variadic()
			.EndBranch()
		.Build()
	)
	CommandServer.register_command(
		CommandBuilder.new().Literal("tp").Validated("x_position", is_valid_float, 0).Validated("y_position", is_valid_float, 0)
		.Build()
	)
	CommandServer.register_command(
		CommandBuilder.new()
			.Literal("alpha")
			.Branch()
				.Literal("bravo")
				.Branch()
					.Literal("echo")
					.Literal("echo")
					.Literal("echo")
				.NextBranch()
					.Literal("fuck")
				.EndBranch()
				.Literal("xray")
			.NextBranch()
				.Literal("charlie")
			.NextBranch()
				.Literal("delta")
			.EndBranch()
		.Build()
	)

func channel_check(args):
	print("Checking channel %s" % [args[2]])

func is_valid_position(_input : String) -> bool: 
	return true

func is_valid_float(input : String) -> bool:
	if not input.is_valid_float():
		CommandServer.push_error("Not a float")
		return false
	return true

func is_valid_dmx_value(input : String) -> bool:
	if not input.is_valid_int():
		CommandServer.push_error("Not an integer")
		return false
	var input_int = int(input)
	if input_int < 0 or input_int > 255:
		CommandServer.push_error("DMX value outside of range (0-255)")
		return false
	return true

func is_valid_channel_index(input : String) -> bool:
	if not input.is_valid_int():
		CommandServer.push_error("Not an integer")
		return false
	var input_int = int(input)
	if input_int < 0 or input_int > 512:
		CommandServer.push_error("Channel index outside of range (0-512)")
		return false
	return true

func is_valid_universe_index(input : String) -> bool:
	if not input.is_valid_int():
		CommandServer.push_error("Not an integer")
		return false
	var input_int = int(input)
	if input_int < 0 or input_int > 63999:
		CommandServer.push_error("Universe index outside of range (0-63999)")
		return false
	return true

var devices_list : Array[String] = [
	"front-laser",
	"back-laser",
	"moving-wash2",
	"fog-machine",
]

func get_dmx_devices_list():
	return devices_list

func dmx_devices_list(_args):
	print("Listing devices...")

func dmx_devices_push(args):
	var device_name = args[2]
	var remaning_args = args.slice(4)
	print("Pushing %s to device '%s'..." % [remaning_args, device_name])

func dmx_override_clear(_args):
	print("Clearing overrides...")

func dmx_override(_args):
	print("Uh uh uhm...")
