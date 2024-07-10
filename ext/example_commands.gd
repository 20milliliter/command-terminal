extends Node

func _ready() -> void:
	# time set day
	CommandBuilder.new()
		.Literal("time").Literal("set").Literal("day").Callback(set_time_day)
	.Build()

	# server players list
	CommandBuilder.new()
		.Literal("server").Literal("players").Literal("list").Callback(print_player_list)
	.Build()

	var video_player : VideoStreamPlayer = $"VideoStreamPlayer"
	# ui videoplayer (play|stop|loop)
	CommandBuilder.new()
		.Literal("ui").Literal("videoplayer")
			.Branch()
				# Callback just wants a callable.
				.Literal("play").Callback(video_player.play)
			.NextBranch()
				# Could be literally anything
				.Literal("stop").Callback(video_player.stop)
			.NextBranch()\
				# Go ahead, do this. Who am I, the feds?
				.Literal("loop").Callback(func() -> void: video_player.loop = !video_player.loop)
			.EndBranch()
	.Build()

	var weekday_names : Array[String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	# time weekday set <day>
	CommandBuilder.new()
		.Literal("time").Literal("weekday").Literal("set").Key("day", func() -> Array[String]: return weekday_names).Callback(set_weekday)
	.Build()

	# object <object_name> destroy
	CommandBuilder.new()
		.Literal("object")
			# Even if the objects in the scene changes, 
			# this list will always be updated by repeatedly calling get_objects_in_scene()
		.Key("object_name", get_objects_in_scene) 
		.Literal("destroy").Callback(destroy_scene_object)
	.Build()

	# server players <player_name> (kick|ban)
	CommandBuilder.new()
		.Literal("server").Literal("players")
			# Same here. If MultiplayerManager.player_names doesn't contain a
			# player because they quit, the terminal will mirror that update.
		.Key("player_name", MultiplayerManager.get.bind("player_names")) 
			# Note: binding get() is "cleaner" than a lambda but definitely slower.
			.Branch()
				.Literal("kick").Callback(MultiplayerManager.kick_player)
			.NextBranch()
				.Literal("ban").Callback(MultiplayerManager.ban_player)
			.EndBranch()
	.Build()

	# set lifeCount <lives>
	CommandBuilder.new().Literal("set").Literal("lifeCount")
		.Validated("lives", is_valid_integer_positive)
		.Callback(set_player_life_count)
	.Build()

	# mp round length <seconds>
	CommandBuilder.new().Literal("mp").Literal("round").Literal("length")
		.Validated("seconds", is_valid_float_positive, 60.0) # An optional default value may be provided
		.Callback(set_multiplayer_round_length)
	.Build()

	# teleport <x-position> <y-position> <z-position> 
	CommandBuilder.new().Literal("teleport")
		.Validated("x-position", is_valid_position, 0) 
		.Validated("y-position", is_valid_position, 0) 
		.Validated("z-position", is_valid_position, 0)
		.Callback(set_player_position)
	.Build()

func get_objects_in_scene() -> Array[String]:
    var objects : Array[String] = []
    for object in get_tree().get_nodes_in_group("scene_objects"):
        objects.append(object.get_name())
    return objects

func is_valid_position(_input : String) -> bool: 
	# Check OOB? Method of doing that differs by game.
	# Or dont, its the console, anyway
	return is_valid_float(_input)

func is_valid_float(input : String) -> bool:
	if not input.is_valid_float():
		CommandServer.push_error("Not a float")
		return false
	return true