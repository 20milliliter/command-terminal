# Using `CommandBuilder`
The `CommandBuilder` is an included builder for creating `ArgumentGraph`s, which are how the addon internally represents commands.

<!---
TODO: Rework formatting of this to be more consistent. really all of it needs reformatting
-->

> _**Note**: The naming here is very intentional. While always linear, command structures are not trees, but graphs, due to certain behaviors of branching._
> <br/>_More on that in that section._

> _**Note**: It is very possible to build an invalid/contradictory/unparseable command with the builder._
> <br/>_A feature to warn the user when this is occuring is planned but not yet implemented._
> <br/>_However, from my testing/analysis, encountering this pretty much requires an obtusely declared command._
> <br/>_If you run into lexing issues, it may be a sign you need to reorganize your command declaration. Feel free to ask me to be sure._

All of `CommandBuilder`'s methods are a part of one of three groups:

1. Arguments
2. Branching
3. Meta (aka everything else)

## Arguments

For arguments, a method exists for each argument type which adds a new argument of that type to the command.
All argument types with examples are viewable on the [Arguments](https://github.com/20milliliter/command-terminal/wiki/Arguments) page.

Branching and meta methods will be described here.

## Branching

Branching methods permit encoding branching command paths into commands.

- Use `Branch()` to begin a branch. Subsequent commands append to the current branch.
- Use `NextBranch()` to finish adding to the current branch, and start the next.
- Use `EndBranch()` to finish the current branch, and continue.

Adding arguments after a Branch is supported. This is useful for commands which have an "option" in the middle that may change a portion of the command signature, but leave the rest the same.

Nesting Branches is supported, but not recommended. If a command with such complexity is required, [register it in chunks](https://github.com/20milliliter/command-terminal/wiki/Using-CommandBuilder#commands-in-chunks) instead.

## Tag

`Tag()` provides the previous argument with a tag. Tagged arguments are arguments which are relevant to a commands implementation, and will need to be parsed when the command is executed.

`Tag()` takes three arguments. First, the `name : StringName` of the tag, then the `type : StringName` of the tagged argument. Finally, the `parser : Callable` to use to parse.

`parser` is an optional argument, as if none is provided, `CommandServer` will search it's registered "global parsers" to find a parser for type `type`.

`Tag_gn()` (given name) is a helper that assumes the tag name based on the argument.
`Tag_gnst()` (given name, stringname type) is a helper that assumes the tag name based on the argument, and assumes the type to be StringName. 

## Callback

`Callback()` registers the previous argument as a point where the command is considered "complete", signified by the `Callable` to invoke in response to this command being entered. When executing a command, the `CommandServer` will search the command's `ArgumentGraph` for the most recent fulfilled argument with a provided `Callback()`, and invoke it.

Multiple callbacks can be provided on a single command. Examples include:
- Multiple commands being registered together for brevity, with a concluding `Branch()` and `Callback()` for each branch.
- A `Callback()` is registered for command where none of its optional arguments are provided, and a second `Callback()` where they are.

The callback function takes a callback `Callable`, and a tag_array `Array[StringName]`. The callback is the `Callable` that CommandServer will invoke to run the command. The tag_array is the arguments the server will provide to that callable, in order, as their tag names as defined by `.Tag*()` calls.

## Optional

`Optional()` signals that all of the arguments after it are optional to the command. This is mostly just to satisfy the lexer.
> _**Note:** If not using separate `Callback()`s, the singular one must be at or before the `Optional()` call, and must be capable of handling none/any of the optional arguments being provided._

## Commands in Chunks

Lastly, a slight recommendation on how to register commands.

**The `CommandServer` retains a singular, traversable graph of registered commands.**
<br/>**`CommandServer.register_command()` is not an append, it is a merge.**

Every multiplayer command (`mp ...`) need not be declared with a single builder and eighty branches.

**Instead, declare every command with a *meaningfully different use*, separately.**

A "single command" may be declared multiple times, outlining different sections of deeper arguments in a clearer form.

```gdscript
# physics override clear
CommandServer.register_command(
	CommandBuilder.new().Literal("physics").Literal("override").Literal("clear")
	# Tagging is unnecessary if the implementation needs no arguments
	.Callback(clear_physics_overrides).Build()
)
# physics override (gravity|friction) <value>
CommandServer.register_command(
	CommandBuilder.new().Literal("physics").Literal("override")
		.Branch()
			.Literal("gravity").Validated("gravity_value", is_valid_float)
			.Tag_gn("float").Callback(set_global_gravity, ["gravity_value"])
		.NextBranch()
			.Literal("friction").Validated("friction_value", is_valid_float)
			.Tag_gn("float").Callback(set_global_friction, ["friction_value"])
		.EndBranch()
	.Build()
)
# physics override player (gravity|friction) <value>
CommandServer.register_command(
	CommandBuilder.new().Literal("physics").Literal("override").Literal("player")
		.Branch()
			.Literal("gravity").Validated("gravity_value", is_valid_float)
			.Tag_gn("float").Callback(set_player_gravity, ["gravity_value"])
		.NextBranch()
			.Literal("friction").Validated("friction_value", is_valid_float)
			.Tag_gn("float").Callback(set_player_friction, ["friction_value"])
		.EndBranch()
	.Build()
)
```

