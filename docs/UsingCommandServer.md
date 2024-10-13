# Using `CommandServer`

The `CommandServer` is an autoload singleton automatically created by the addon when enabled.

It is responsible for all interface between the addon and the rest of the codebase, and has two methods.

### func register_command(command_graph : ArgumentGraph) -> void

This method registers a new command to the server. Every command must be registered to be able to be ran. Commands cannot be unregistered once registered. 

Its only argument is an `ArgumentGraph`. `ArgumentGraph`s are how the addon represents commands internally; They are not to be made directly. Instead, use the `CommandBuilder`.
All of your command registrations should look like this:
```gdscript
func _ready() -> void:
    CommandServer.register_command(
        CommandBuilder.new()
            #... your command ...
        .Build()
    )
```

More information on using the `CommandBuilder` can be found in [Using CommandBuilder](UsingCommandBuilder.md).

### func register_parser(type : StringName, parser : Callable) -> void

This method registers a new parser with the CommandServer. Without parsers, CommandServer can only call provided methods with `String` arguments (thus helper methods for every command would have to exist).

It takes a StringName of the type to parse and the callable to call. The provided callable should take only one argument, a String, and return a type `type`. 

Here is an example of a simple float parser:
```gdscript
func parse_float(value : String) -> float:
	if value.is_valid_float():
		return float(value)
	else:
		return NAN
```
And how it would be registered:
```gdscript
CommandServer.register_parser("float", parse_float)
```

A parser registered in this way is a "global parser". Any argument of a given `type` will use this parser method to be parsed, unless a different parser is specified during command creation.

<!---
TODO: Probably make mention of why I don't include any parsers (force the user to recognize wtf they doin)
-->

### func run_command(command : String) -> void

This method runs the provided command, and takes appropriate action based on if it is valid or not.

This method is called by the `CommandTerminal` node automatically, but is also exposed if you wish to run a command from somewhere else.