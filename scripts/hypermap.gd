class_name HyperMap
extends Object


var _result_array: Array
var _started: bool = false
var _group_task_id: int

	
func is_completed() -> bool:
	assert(_started, "Task has not been started yet.")
	return WorkerThreadPool.is_group_task_completed(_group_task_id)
	
	
func is_started() -> bool:
	return _started
	
	
func start(method: Callable, elements: Array) -> void:
	assert(not _started, "Cannot start another task until current one is completed.")
	_result_array = []
	_result_array.resize(len(elements))
	var task: Callable = func(i: int) -> void:
		_result_array[i] = method.call(elements[i])
	_group_task_id = WorkerThreadPool.add_group_task(task, len(elements))
	_started = true
	

func wait_for_result() -> Array:
	assert(_started, "Task has not been started yet.")
	WorkerThreadPool.wait_for_group_task_completion(_group_task_id)
	_started = false
	return _result_array
