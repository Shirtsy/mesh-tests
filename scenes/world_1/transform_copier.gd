extends Node3D


@export var target: Node3D


func _ready() -> void:
	assert(target, "Target has not been assigned.")


func _process(_delta: float) -> void:
	transform = target.transform
