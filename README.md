# command-terminal

CommandTerminal is an addon for Godot 4 that manages a user-created Command Line. Commands can be registered from anywhere in the codebase with `CommandServer.register_command()` and executed from a CommandLine control node to be placed in your project.

## Features

- CommandServer
	- Central command storage. Accepts new commands at any time!
- CommandBuilder
	- Define command structure easily!
- CommandLine
	- Autocompletion out of the box!

## Usage
1. Place a CommandLine node in your UI.
2. Call `CommandServer.register_command()` with command structure and a callback which implements the command.
3. Enter the command into the CommandLine.

## Installation

Installing is as easy as cloning this repo into your project as a submodule.
Use `git submodule add https://github.com/20milliliter/command-terminal.git ./addons/command-terminal` and enable the plugin in the editor.

Alternatively, you can install it manually by downloading the zip.