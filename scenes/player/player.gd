extends CharacterBody3D


@export var speed: float = 5.0
@export var rotation_speed: float = 1.0


var mouse_delta: Vector2


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().quit()
	if event.is_action_pressed("scroll_up"):
		speed = min(speed + 10_0000, 10_000_000)
	elif event.is_action_pressed("scroll_down"):
		speed = max(speed - 10_0000, 1000)
		
	if event is InputEventMouseMotion:
		mouse_delta = event.screen_relative


func _process(_delta: float) -> void:
	rotation = rotation + (Vector3(-mouse_delta.y, -mouse_delta.x, 0) * rotation_speed * 0.005)
	rotation.x = clamp(rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))
	mouse_delta = Vector2.ZERO


func _physics_process(delta: float) -> void:
	var x_in: float = Input.get_axis("left", "right")
	var y_in: float = Input.get_axis("down", "up")
	var z_in: float = Input.get_axis("forward", "back")
	var move_dir: Vector3 = (global_basis * Vector3(x_in, y_in, z_in)).normalized()
	velocity = move_dir * speed * delta
	move_and_slide()
