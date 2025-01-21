extends Label


@export var node_1: Node3D
@export var node_2: Node3D


var ups: float = 0
var updates: int = 0


func _ready() -> void:
	assert(node_1 and node_2, "Not all nodes have been initialized.")


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() % 5000 == 0:
		ups = updates / 5.0
		updates = 0
	text = (
			"Distance: " + str(
				node_1.global_position.distance_to(node_2.global_position) - node_2.radius
			)
			+ "\n" + "Speed: " + str(node_1.speed)
			+ "\n" + "FPS: " + str(Engine.get_frames_per_second())
			+ "\n" + "UPS: " + str(ups)
	)


func _on_quad_planet_mesh_updated() -> void:
	updates += 1
