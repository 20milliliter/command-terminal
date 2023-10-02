@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("CommandServer", "res://addons/command-terminal/src/CommandServer.gd")

func _exit_tree():
	remove_autoload_singleton(name)