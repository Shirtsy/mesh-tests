extends Node


var t1: int
var test_array: Array[float]


func _ready() -> void:
	build_array()
	
	t1 = Time.get_ticks_msec()
	var arr_3: Array = map_array(test_array)
	print("Map: " + str(Time.get_ticks_msec() - t1))
	
	t1 = Time.get_ticks_msec()
	var arr_2: Array = loop_over_array(test_array)
	print("Loop: " + str(Time.get_ticks_msec() - t1))

	get_tree().quit.call_deferred()


func build_array() -> void:
	for i: int in 1_000_000:
		test_array.append(1.0)


func loop_over_array(arr: Array[float]) -> Array[float]:
	var result_arr: Array[float]
	var packed_arr: PackedFloat64Array = []
	for x: float in PackedFloat64Array(arr):
		packed_arr.append(mult(x))
	result_arr.assign(packed_arr)
	return result_arr
	
	
func map_array(arr: Array[float]) -> Array[float]:
	var result_arr: Array[float]
	result_arr.assign(arr.map(mult))
	return result_arr
	
	
func mult(x: float) -> float:
	return x * 2.0
