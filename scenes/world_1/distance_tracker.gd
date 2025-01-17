extends Label


@export var node_1: Node3D
@export var node_2: Node3D


func _ready() -> void:
	assert(node_1 and node_2, "Not all nodes have been initialized.")


func _process(_delta: float) -> void:
	text = (
			"Distance: " + str(
				node_1.global_position.distance_to(node_2.global_position) - node_2.radius
			)
			+ "\n" + "Speed: " + str(node_1.speed)
			+ "\n" + "FPS: " + str(Engine.get_frames_per_second())
	)
