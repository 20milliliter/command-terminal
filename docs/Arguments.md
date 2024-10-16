# Arguments
The following is a list of all Argument types, with examples for each illustrating their intended use.

## Literal

A Literal Argument is an argument represented by a String literal.

### Examples
```gdscript
# time set day
CommandBuilder.new()
    .Literal("time").Literal("set").Literal("day").Callback(set_time_day)
.Build()
```
```gdscript
# server players list
CommandBuilder.new()
    .Literal("server").Literal("players").Literal("list").Callback(print_player_list)
.Build()
```
```gdscript
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
```

## Key

A Key Argument is an argument that can be one of a set of StringName keys.
The set of possible keys is retrieved from a Callable, provided on initialization.

_**Note:** The set of possible keys is not fixed, the Callable may provide any set/subset arbitrarily._

### Examples
```gdscript
var weekday_names : Array[StringName] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
# time weekday set <day>
CommandBuilder.new()
    .Literal("time").Literal("day").Literal("set")
	.Key("day", func() -> Array[StringName]: return weekday_names).Tag_gnst()
	.Callback(set_weekday, ["day"])
.Build()
```
```gdscript
# object <object_name> destroy
CommandBuilder.new()
    .Literal("object")
        # Even if the objects in the scene changes, 
        # this list will always be updated by repeatedly calling get_objects_in_scene()
    .Key("object_name", get_objects_in_scene).Tag_gn("Object")
    .Literal("destroy").Callback(destroy_scene_object, ["object_name"])
.Build()

func get_objects_in_scene() -> Array[String]:
    var objects : Array[String] = []
    for object in get_tree().get_nodes_in_group("scene_objects"):
        objects.append(object.get_name())
    return objects
```
```gdscript
# server players <player_name> (kick|ban)
CommandBuilder.new()
    .Literal("server").Literal("players")
        # Same here. If MultiplayerManager.player_names doesn't contain a
        # player because they quit, the terminal will mirror that update.
    .Key("player_name", MultiplayerManager.get.bind("player_names"))
        # Note: binding get() is "cleaner" than a lambda but slower.
	.Tag("player_id", "int", MultiplayerManager.player_names_to_peer_id_dictionary.get)
        .Branch()
            .Literal("kick").Callback(MultiplayerManager.kick_player, ["player_id"])
        .NextBranch()
            .Literal("ban").Callback(MultiplayerManager.ban_player, ["player_id"])
        .EndBranch()
.Build()
```

## Validated

A ValidatedArgument is an argument that is associated with a Callable to determine if a given input is valid.
It's primary use-case is for numerical arguments.

### Examples
```gdscript
# set lifeCount <lives>
CommandBuilder.new().Literal("set").Literal("lifeCount")
    .Validated("lives", is_valid_integer_positive).Tag_gn("int")
    .Callback(set_player_life_count, ["lives"])
.Build()
```
```gdscript
# mp round length <seconds>
CommandBuilder.new().Literal("mp").Literal("round").Literal("length")
    .Validated("seconds", is_valid_float_positive, 60.0) # An optional default value may be provided
	.Tag_gn("float").Callback(set_multiplayer_round_length, ["seconds"])
.Build()
```
```gdscript
# teleport <x-position> <y-position> <z-position> 
CommandBuilder.new().Literal("teleport")
    .Validated("x-position", is_valid_float, 0).Tag_gn("float")
    .Validated("y-position", is_valid_float, 0).Tag_gn("float")
    .Validated("z-position", is_valid_float, 0).Tag_gn("float")
    .Callback(set_player_position, ["x-position", "y-position", "z-position"])
.Build()
```

## Variadic

A VariadicArgument is an argument that represents the command accepting any number of extra arguments at it's end.

### Examples

```gdscript
# chat say ...
CommandBuilder.new()
    .Literal("chat").Literal("say").Variadic().Tag("message", "StringName").Callback(send_chat_message, ["message"])
.Build()
```