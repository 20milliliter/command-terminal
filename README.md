# command-terminal

CommandTerminal is a GDScript addon for Godot 4 that manages a developer-created Command Line, with the goal of providing flexible commands, with direct but safe interaction with business logic, through readable command declarations.

Features include:

- `CommandServer` to register and execute commands, anywhere and anytime.
- `CommandBuilder` to easily create powerful, flexible, and type-safe commands.
- `CommandTerminal` to input commands, with included rich autocompletion, and live validation.

## Installation

You can install the addon as a git submodule:
`git submodule add https://github.com/20milliliter/command-terminal.git ./addons/command-terminal`

Alternatively, you can install it manually by downloading the zip.

## Overview

Suppose your project is a 2D-platformer that has a `player.gd` script for a `CharacterBody2D`:

```gdscript
class_name Player extends CharacterBody2D

signal coin_collected()

var WALK_SPEED = 300.0
var ACCELERATION_SPEED = WALK_SPEED * 6.0
var JUMP_VELOCITY = 725.0
var TERMINAL_VELOCITY = 700

var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
```

> [!NOTE]
> Everything done hereafter requires no alterations to the above code.

Creating a command to give the player a coin may be done by emitting the `coin_collected()` signal when it is ran. The following code creates command "player give coin" to do just that.
```gdscript
func register_commands() -> void:
    CommandServer.register_command(
        CommandBuilder.new()
            .Literal("player").Literal("give").Literal("coin")
            .Callback(player.coin_collected.emit)
        .Build()
    )
```

The following code creates command "player set walk_speed <value>" to alter `WALK_SPEED`. Values inputted that are not positive integers are visibly flagged. Validated arguments supply their default value when autocompleteed.
```gdscript
func register_commands() -> void:
    CommandServer.register_command(
        CommandBuilder.new()
            .Literal("player").Literal("set").Literal("walk_speed")
            .Validated("value", _is_valid_float_positive, 300).Tag_gn("float")
            .Callback(player.set, ["WALK_SPEED", "value"])
        .Build()
    )

func _is_valid_float_positive(s : String) -> bool:
    if not value.is_valid_float(): return false
    var value : float = float(value)
    return value > 0
```

> [!TIP]
> Validators such as `_is_valid_float_positive` can be declared in a static holder class and reused everywhere.

## Documentation

Documentation is included within the addon under [`./docs/`](/docs/). The markdown is best viewed on github.

Exposed classes also feature doc comments for in the editor.
