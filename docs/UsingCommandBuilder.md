# Using `CommandBuilder`
The `CommandBuilder` is an included builder for creating `ArgumentGraph`s, which are how the addon internally represents commands.

> [!NOTE]
> The naming here is very intentional. 
> While always linear, command structures are not trees, but graphs, due to certain behaviors of branching.
> More on that in that section.

> [!WARNING]
> It is very possible to build an invalid/contradictory/unparseable command with the builder.
> A feature to warn the user when this is occuring is planned for the future.
>
> However, from my testing/analysis, encountering this pretty much requires a badly declared command.
> If you run into lexing issues, it may be a sign you need to reorganize your command declaration. Feel free to ask me to be sure.

All of `CommandBuilder`'s methods are in one of three groups:

1. Arguments
2. Branching
3. Meta (aka everything else)

## Arguments

For arguments, a method exists for each argument type which adds a new argument of that type to the command. Methods include:

- `Literal()`
- `Key()`
- `Validated()`
- `Variatic()`

Information about argument types, with examples, can be found [here](Arguments.md).

## Branching

Branching methods permit encoding branching command paths into commands.

- `Branch()` begins a branch. Subsequent arguments append to only the current branch.
- `NextBranch()` finishes the current branch, and begins a new branch.
- `EndBranch()` finishes the current branch. Subsequent arguments append to all branches.

>[!TIP]
> Adding arguments after a Branch is supported. This is useful for commands which have an "option" in the middle that adds an argument or two, but leaves the rest the same.

>[!WARNING]
> Nesting Branches is supported, but generally not recommended.
> If a command with such complexity is required, consider [registering it in chunks](BestPractices.md#commands-in-chunks) instead.

## Meta

### Tag

`Tag()` provides the previous `Argument` with a tag. Tagged `Argument`s are arguments which are relevant to a commands implementation, and will need to be parsed when the command is executed.

The method takes three arguments. First, the `name : StringName` of the tag, then the `type : StringName` of the tagged argument, and the `parser : Callable` to use to parse it.

The `parser` is an optional argument. If none is provided, `CommandServer` will search it's registered "global parsers" to find a parser for type `type`.

More information about parsers can be found [here](UsingCommandServer.md#register-Parser).

`CommandBuilder` also provides three helper methods for more terse tagging:

- `Tag_gn()` (given name) populates the tag name based on the argument.
- `Tag_st()` (stringname type) populates the type as `&"StringName"`.
- `Tag_gnst()` (given name, stringname type) populates the tag name based on the argument, and populates the type as `&"StringName"`.

> [!NOTE]
> Given names are retrieved as follows:
>
> - `Literal` - the provided literal
> - `Key` - the provided name
> - `Validated` - the provided name
> - `Variadic` - `&"..."`

### Callback

`Callback()` registers the previous argument as a point where the command is considered "complete", via a `Callable` to invoke when the command is entered.

> [!NOTE]
> Multiple callbacks can be provided on a single command. When executing a command, the `Callback()` that is invoked is the the deepest which can be validly reached.
>
> Examples include:
>
> - Multiple simple commands being built together for brevity, with a concluding `Branch()` and `Callback()` for each branch.
> - A `Callback()` is registered for command where none of its optional arguments are provided, and a second `Callback()` where they are.

The function takes a `callback : Callable` that `CommandServer` will invoke to run the command, and `arguments : Array[Variant]` that the server will provide to that callable, in order, when invoked. If a `StringName` argument matches the name of a `.Tag*()`ed argument, the content of the tagged argument is parsed and substituted.

> [!WARNING]
> `Callable.bind()` sucks, actually. (It works in an unintuitive way.)
> <br/> Unless you are familiar with `bind()` and `unbind()`, `bind()`ing a `Callable` passed into `Callback()` will probably not do what you expect. If you wish to provide extra arguments to a command's implementing `Callable`, include their symbol literals in the arguments array.

### Optional

`Optional()` signals that all of the arguments after it are optional to the command. This is mostly just to satisfy the lexer.

<!---

TODO: Pretty confident below is straight cap. Optional() needs testing like at all 

> [!NOTE]
> If not using separate `Callback()`s, the singular one must be at or before the `Optional()` call, and must be capable of handling none/any of the optional arguments being provided.

-->
