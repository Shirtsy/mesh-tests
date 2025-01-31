extends MeshInstance3D


signal mesh_updated


@export var collider: CollisionShape3D
@export var radius: float = 1.0
@export var marker: Node3D
@export var lod_distances: PackedFloat64Array
@export var multi_noise: Noise


var thread: Thread = Thread.new()



func _ready() -> void:
	assert(marker, "Marker Node3D not set.")
	assert(multi_noise, "MultiNoise not set.")
	assert(collider, "Collider not set.")
	var result: Dictionary[String, Variant] = PlanetUtils.generate_planet_meshes(
			radius,
			marker.position - position,
			lod_distances,
			multi_noise
	)
	mesh = result.draw
	collider.shape = result.collider
	#print("Mesh Vert Count: ", mesh.surface_get_array_len(Mesh.ARRAY_VERTEX))


func _process(_delta: float) -> void:
	if not thread.is_started():
		thread.start((
			PlanetUtils.generate_planet_meshes
		).bind(radius, marker.global_position - global_position, lod_distances, multi_noise))
	elif not thread.is_alive():
		var thread_result: Dictionary[String, Variant] = thread.wait_to_finish()
		# print(len(thread_result.draw.get_faces()))
		mesh = thread_result.draw
		collider.shape = thread_result.collider
		mesh_updated.emit()
