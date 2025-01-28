extends Node

func _ready() -> void:
	var test_lambda: Callable = func(operation: Callable) -> void:
		print("Uh oh this is forever!")
		operation.call(operation)
	test_lambda.call(test_lambda)
