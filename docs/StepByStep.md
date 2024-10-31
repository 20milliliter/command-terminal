# Step by Step

The following is a loose step-by-step-formatted overview of how a command is registered and executed within the addon. It may be useful if troubleshooting is required, if addon-included warns/errors alone are insufficient.

## Steps

### Building the command

Commands are created using `CommandBuilder`. They instantiate an `ArgumentGraph`, method calls modify the graph, and `.Build()` returns the result.

### Registering the command

Once the command is built, and `ArgumentGraph` returned, you should not really do anything with it besides immediately registering with `CommandServer.register_command()`.

Doing so will take the provided `ArgumentGraph`, and the existing `ArgumentGraph` in `CommandServer` (which contains every command already registered) and merges the former into the latter.

### Typing the command

Yes this is a real step. This is because the addon features live lexing.

Every time the contents of the `CommandTerminal` node changes, it re-lexes (not always entirely, some caching occurs) the text to determine what visual feedback to display.

I feel as though the functionality of the lexer itself has little relevance to the user. If you believe otherwise, raise a github issue.

### Running the command

Running the command is done by submitting on the `CommandTerminal` node, or running `CommandServer.run_command()` (which is what the node does).

### Invoking the command callback

When a command is requested to be executed, `CommandServer` does the following things:

1. Lex the command again
2. Traverse the result to find the deepest node that necessitates a "complete" command (`Callback()` present, all arguments are valid)
3. Assemble the array of arguments to call by searching for tags, and calling parsers
4. Invoke the the callback Callable with the arguments
