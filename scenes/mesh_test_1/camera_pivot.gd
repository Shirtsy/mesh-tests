extends Node3D


@export var speed: float = 5.0
@export var zoom_scale: float = 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rotation_vec: Vector2 = Input.get_vector("left", "right", "down", "up")
	rotation.y += rotation_vec.x * speed * delta
	rotation.x += rotation_vec.y * speed * delta * -1
	var zoom_vec: float = Input.get_axis("left_click", "right_click")
	scale += Vector3.ONE * zoom_vec * zoom_scale * delta
