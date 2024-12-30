extends Node3D


@export var speed: float = 5

var input_vec: Vector2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	input_vec = Input.get_vector("left", "right", "down", "up")
	rotation.y += input_vec.x * speed * delta
	rotation.x += input_vec.y * speed * delta * -1
