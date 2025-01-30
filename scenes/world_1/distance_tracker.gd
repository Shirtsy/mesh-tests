extends Label


@export var node_1: Node3D
@export var node_2: Node3D


var gen_start_time: float = 0.0
var gen_time: float = 0.0


func _ready() -> void:
	assert(node_1 and node_2, "Not all nodes have been Snitialized.")


func _process(_delta: float) -> void:
	text = (
			"Distance: " + str(
				node_1.global_position.distance_to(node_2.global_position) - node_2.radius
			)
			+ "\n" + "Speed: " + str(node_1.speed)
			+ "\n" + "FPS: " + str(Engine.get_frames_per_second())
			+ "\n" + "Gen: " + str(gen_time)
	)


func _on_quad_planet_mesh_updated() -> void:
	gen_time = (Time.get_ticks_msec() - gen_start_time) / 1000.0
	gen_start_time = Time.get_ticks_msec()


func _on_cs_quad_planet_mesh_updated() -> void:
	gen_time = (Time.get_ticks_msec() - gen_start_time) / 1000.0
	gen_start_time = Time.get_ticks_msec()
