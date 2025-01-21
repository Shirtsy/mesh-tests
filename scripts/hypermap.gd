## Wraps [WorkerThreadPool] to allow for easier multithreaded mapping of
## a [Callable] to an [Array].
class_name HyperMap
extends RefCounted


var _input_array: Array
var _result_array: Array
var _started: bool = false
var _group_task_id: int


## Returns [code]true[/code] if mapping is completed. Returns [code]false[/code]
## if mapping is not complete or has not been started.
func is_completed() -> bool:
	if not _started:
		return false
	else:
		return WorkerThreadPool.is_group_task_completed(_group_task_id)
	

## Returns [code]true[/code] if mapping has been started.
func is_started() -> bool:
	return _started
	

## Starts mapping task. [Callable] should accept and return a single [Variant].
func start(method: Callable, elements: Array) -> void:
	assert(not _started, "Cannot start another mapping task until current one is completed.")
	_input_array = elements.duplicate(true)
	_result_array = []
	_result_array.resize(len(_input_array))
	var task: Callable = func(i: int) -> void:
		_result_array[i] = method.call(_input_array[i])
	_group_task_id = WorkerThreadPool.add_group_task(task, len(_input_array))
	_started = true
	

## Pauses the thread until results are ready, then returns them.
func wait_for_result() -> Array:
	assert(_started, "Mapping task has not been started yet.")
	WorkerThreadPool.wait_for_group_task_completion(_group_task_id)
	_started = false
	return _result_array
