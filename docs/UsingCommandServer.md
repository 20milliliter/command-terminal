# Using `CommandServer`

The `CommandServer` is an autoload singleton automatically created by the addon when enabled.

It is responsible for facilitating all interaction between the addon and your project's business logic.

## Methods

### Register Command

> [!NOTE]
> Every command must be registered to be able to be ran.
> <br/>Commands cannot be unregistered once registered.

`register_command(command_graph : ArgumentGraph)` registers a new command to the server.

> [!IMPORTANT]
> `ArgumentGraph`s are how the addon represents commands internally: **They are not to be created manually**. Instead, use the included `CommandBuilder`.
>
> All command registrations should look like this:
>
> ```gdscript
> func foo() -> void:
>     CommandServer.register_command(
>         CommandBuilder.new()
>             #... your command ...
>         .Build()
>     )
> ```
>
> More information on using the `CommandBuilder` can be found [here](UsingCommandBuilder.md).

### Register Parser

`register_parser(type : StringName, parser : Callable)` registers a new parser with the `CommandServer`. The method takes `type : StringName` to parse and a `parser : Callable` which implements the parsing logic.

The `parser` should be a developer-declared method which takes a `String` argument and returns a type `type`. A parser should be created for every datatype that is relevant to commands you wish to create for your codebase.

Without parsers, `CommandServer` could only call provided callbacks with `String` arguments (thus helper methods for every command would have to exist).

Here is an example of a simple float parser:

```gdscript
func parse_float(value : String) -> float:
	# Validating parser input is technically not required, as 
	# any value that cannot be parsed should be deemed invalid 
	# by the argument's validator before it can get here.
	#
	# Still probably should to be safe, for instance if 
	# theres issues with a validator's implementation

	if value.is_valid_float():
		return float(value)
	else:
		return NAN 
```

And how it would be registered:

```gdscript
CommandServer.register_parser("float", parse_float)
```

A parser registered in this way is a "global parser". Any argument of a given `type` will use this parser method to be parsed, unless an overriding parser is specified during command creation.

> [!IMPORTANT]
> The addon comes with no included parsers.
> Not even "simple" ones that would use conversion methods already present in `@GlobalScope`, as:
>
> 1. the decision of where to stop would be arbitrary.
> 2. it felt healthier to make the user write the parsers themselves so it is not happening behind a veil, nor risking dirty exceptions.

> [!TIP]
> A parser's primary purpose is not validation. That is taken care of by validators.
> <br/>The primary purpose is to parse `String` input so that business logic may be called with type-safety.
> <br/>As such, you should probably have more declared validators than parsers.
>
> For instance, suppose validators `is_valid_int()`, `is_valid_int_positive()`, and `is_valid_int_negative()`.
> <br/>They all have different conditions for being a "valid" input in their respective contexts, but at call-time, type-safety only nessecitates one parser, `parse_int()`.

### Run Command

`run_command(command : String)` executes the provided command. This method is called by the `CommandTerminal` node when executing a command, but is also exposed if you wish to run a command from somewhere else.

> [!NOTE]
> If the command (specifically at least one of its arguments) is determined to be invalid, it will silently not run (it actually isn't truly silent, but the point is that it's not *not silent* enough).
> <br/>Functionality to provide more useful feedback/errors with inputted commands is planned for the future.
