extends CollisionShape3D


@export var planet: QuadPlanet
@export var lod_distances: Array[float]


@onready var radius: float = planet.radius
@onready var marker: Node3D = planet.marker
@onready var noise_mult: float = planet.noise_mult
@onready var multi_noise: MultiNoise = planet.multi_noise


var thread: Thread = Thread.new()


func _process(_delta: float) -> void:
	if not thread.is_started():
		thread.start((
			func(rad: float, marker_pos: Vector3, lod_dist: Array[float], noi: MultiNoise, noi_mult: float) -> Shape3D:
					return QuadPlanet.generate_mesh(rad, marker_pos, lod_dist, noi, noi_mult).create_trimesh_shape()
		).bind(radius, marker.position - position, lod_distances, multi_noise, noise_mult))
	elif not thread.is_alive():
		shape = thread.wait_to_finish()
