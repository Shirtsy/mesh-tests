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
	
	var marker_dist: float = Vector3.ZERO.distance_to(marker_pos)
	
	# Generate first plane verts
	vertices.append(Vector3(rad, rad, rad))
	vertices.append(Vector3(-rad, rad, rad))
	vertices.append(Vector3(rad, -rad, rad))
	vertices.append(Vector3(-rad, -rad, rad))
	
	indices.append_array([2, 1, 0])
	indices.append_array([1, 2, 3])
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	#surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	print(surface_array[Mesh.ARRAY_VERTEX])
	print(surface_array[Mesh.ARRAY_INDEX])
	return surface_array
#endregion
