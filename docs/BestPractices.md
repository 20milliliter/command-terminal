
# Best Practices

The following are some "best practices" with regard to using the addon.

## Declaring commands "in chunks"

Due to the architecture of the internal command storage, it is possible to register a "single command" in multiple chunks for the sake of readability. Every multiplayer command (`mp ...`) need not be declared with a single builder and eighty branches.

Said architecture is a singular, traversable graph of registered commands. `CommandServer.register_command()` is not an *append*, it is a **merge**.

> [!TIP]
> Declare every "command" (section of a command) with a *meaningfully different use*, separately. 
> </br>Alternatively, create a limit for the number of `Callback()`s called on one builder (for instance, 4).

### Example

```gdscript
# "Full" command:
# physics 
#         override 
#                  clear
#                  (gravity|friction) 
#                                     <value>
#                  player 
#                         (gravity|friction) 
#                                            <value>

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
            .Tag_gn("float").Callback(player.set_gravity, ["gravity_value"])
        .NextBranch()
            .Literal("friction").Validated("friction_value", is_valid_float)
            .Tag_gn("float").Callback(player.set_friction, ["friction_value"])
        .EndBranch()
    .Build()
)
```

## Reccomendations on Validators and Parsers

To use the addon as intended, several validators and parsers must be declared by the developer. They both can be declared in certain ways to be easily referenced and reused.

### Validators

Validators can be static, thus be declared in a `class_name` scope and freely referenced. Below is an example of such as an excerpt from one of my projects:

```gdscript
class_name GlobalCommandValidators
extends RefCounted

static func is_valid_string(value : String) -> bool:
    return true

static func is_valid_int(value : String) -> bool:
    return value.is_valid_int()

static func is_valid_float(value : String) -> bool:
    return value.is_valid_float()

static func is_valid_filepath(value : String) -> bool:
    return is_valid_absolute_filepath(value) or is_valid_relative_filepath(value)

static func is_valid_absolute_filepath(value : String) -> bool:
    return value.is_absolute_path()

static func is_valid_relative_filepath(value : String) -> bool:
    return value.is_relative_path()

static func is_valid_filename(value : String) -> bool:
    return value.is_valid_filename()

static func is_sensible_bpm(value : String) -> bool:
    if not value.is_valid_int(): return false
    var int_value : int = int(value)
    var in_sensible_range : bool = int_value >= 24 and int_value <= 660
    return in_sensible_range
```

### Parsers

The same is true for Parsers, with the exception that they need to be registered at runtime. In the below case (again, an excerpt), `register_global_parsers()` is called at project run by an autoload.

```gdscript
class_name CommandTerminalGlobalParsers
extends RefCounted

static func register_global_parsers() -> void:
    CommandServer.register_parser("int", parse_int)
    CommandServer.register_parser("float", parse_float)
    return

static func parse_int(value : String) -> int:
    return int(value)

static func parse_float(value : String) -> float:
    return float(value)
```
