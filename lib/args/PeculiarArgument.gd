class_name PeculiarArgument
extends Argument
## The abstract intermediate class for some Argument types.
##
## The abstract intermediate class for some Argument types.
## A PeculiarArgument is an Argument that has a special behavior related to autofill–that being that the content the autofill UI shows to represent the Argument is not actually what is placed in the terminal when it is autofilled. [br][br]
## [b]Note: Full disclosure, I just could not think of an decent name for this class so I asked ChatGPT and it said PeculiarArgument and I thought it was the funniest fing thing ever so here we are. [i]There is really no reason to be referencing this class.[/i][/b]

func get_autofill_content() -> String: #virtual
	assert(false, "'get_autofill_content()' called on PeculiarArgument that does not implement it.")
	return ""