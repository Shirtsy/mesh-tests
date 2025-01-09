class_name QuadPlanet
extends MeshInstance3D


@export var radius: float = 1.0
@export var marker: Node3D
@export var noise: Noise

@export var lod_distances: Array[float]


func _ready() -> void:
	mesh = ArrayMesh.new()
	var surface_array: Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array = generate_quadplanet_array(radius, marker.position, lod_distances)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	
func _process(_delta: float) -> void:
	pass


#region Static functions
static func generate_quadplanet_array(rad:float, marker_pos: Vector3, lod_dist: Array[float]) -> Array:
	var surface_array: Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	
	var quad_indices: Array[Array] = []
	
	# Generate first plane verts
	vertices.append(Vector3(rad, rad, rad))
	vertices.append(Vector3(rad, -rad, rad))
	vertices.append(Vector3(-rad, -rad, rad))
	vertices.append(Vector3(-rad, rad, rad))
	var quad: Array[int] = [0, 1, 2, 3]
	
	if quad.any(
			func(x: int) -> bool:
				return true if marker_pos.distance_to(vertices[x]) < lod_dist[0] else false
	):
		var new_quads: Array[Array] = []
		var new_verts: PackedVector3Array = PackedVector3Array()
		for i: int in quad:
			new_verts.append(vertices[i].lerp(vertices[(i % 3) + 1], 0.50))
		new_verts.append(quad.reduce(
			func(accum: Vector3, x: int) -> Vector3:
				return accum + vertices[x]
		, Vector3.ZERO) / 4)
		vertices.append_array(new_verts)
		new_quads.append([
			quad[0],
			len(vertices) - 5,
			len(vertices) - 1,
			len(vertices) - 2
		])
		quad_indices.append_array(new_quads)
	else:
		quad_indices.append(quad)
	
	for i_quad: Array[int] in quad_indices:
		indices.append_array(i_quad.slice(0, 3))
		indices.append_array(i_quad.slice(2, 4))
		indices.append(i_quad[0])
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	#surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	print(surface_array[Mesh.ARRAY_VERTEX])
	print(surface_array[Mesh.ARRAY_INDEX])
	return surface_array
	
	
## Appends value to array and returns index of new value
static func i_append(x: Variant, arr: Array) -> int:
	arr.append(x)
	return len(arr)
	
	
static func any_within_distance(pos: Vector3, dist: float, points: Array[Vector3]) -> bool:
	return points.any(
			func(x: Vector3) -> bool:
				return true if pos.distance_squared_to(x) < (dist ** 2) else false
	)
#endregion
