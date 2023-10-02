#class_name CommandServer
extends Node

var argument_tree : ArgumentGraph

func register_command(argument_tree : ArgumentGraph):
	argument_tree.merge(argument_tree)