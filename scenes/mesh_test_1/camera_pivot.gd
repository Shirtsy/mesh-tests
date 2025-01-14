extends Node3D


@export var speed: float = 5.0
@export var zoom_scale: float = 1.0
@export var arrow_keys: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rotation_vec: Vector2
	if not arrow_keys:
		rotation_vec = Input.get_vector("left", "right", "down", "up")
	else:
		rotation_vec = Input.get_vector("l_a", "r_a", "d_a", "u_a")
	rotation.y += rotation_vec.x * speed * delta
	rotation.x += rotation_vec.y * speed * delta * -1
	var zoom_vec: float = Input.get_axis("left_click", "right_click")
	if not arrow_keys:
		scale += Vector3.ONE * zoom_vec * zoom_scale * delta
