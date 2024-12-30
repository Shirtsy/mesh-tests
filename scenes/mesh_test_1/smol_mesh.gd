class_name SmolMesh
extends MeshInstance3D


@export var enabled: bool = false
@export var radius: float = 1.0
@export var subdivisions: int = 1


func _ready() -> void:
	mesh = ArrayMesh.new()
	update_mesh(radius, subdivisions)


func _process(_delta: float) -> void:
	if enabled:
		update_mesh(radius, subdivisions)
	
	
func update_mesh(rad: float, subdiv: int) -> void:
	mesh.clear_surfaces()
	var surface_array: Array = generate_mesh_array(rad, subdiv)
	
	#var surface_tool:SurfaceTool = SurfaceTool.new()
	#surface_tool.create_from_arrays(surface_array, 0)
	#surface_tool.generate_normals()
	#surface_tool.generate_tangents()
	#var surface_array_2: Array = surface_tool.commit_to_arrays()
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	
static func generate_mesh_array(rad: float, subdiv: int) -> Array:
	var surface_array: Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var vertices: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	var normals: PackedVector3Array = PackedVector3Array()

	# Calculate vertex spacing
	var distance: float = rad / subdiv

	# Generate vertices
	for y: int in range(subdiv + 1):
		for x: int in range(subdiv + 1):
			var x_pos: float = (x * distance) - (rad / 2)
			var y_pos: float = (y * distance) - (rad / 2)
			vertices.append(Vector3(x_pos, y_pos, rad / 2))

	# Generate indices for triangles
	for y: int in range(subdiv):
		for x: int in range(subdiv):
			var vertex_index: int = x + y * (subdiv + 1)
			 # First triangle of quad
			indices.append(vertex_index + subdiv + 1)
			indices.append(vertex_index + 1)
			indices.append(vertex_index)
			# Second triangle of quad
			indices.append(vertex_index + subdiv + 1)
			indices.append(vertex_index + subdiv + 2)
			indices.append(vertex_index + 1)
			
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	var surface_2: Array = surface_array.duplicate(true)
	rotate_mesh_array(surface_2, Vector3.LEFT, 90.0)
	boolean_mesh_arrays(surface_array, surface_2)
	rotate_mesh_array(surface_2, Vector3.FORWARD, 90.0)
	boolean_mesh_arrays(surface_array, surface_2)
	surface_2 = surface_array.duplicate(true)
	rotate_mesh_array(surface_2, Vector3.FORWARD, 180.0)
	rotate_mesh_array(surface_2, Vector3.UP, -90.0)
	boolean_mesh_arrays(surface_array, surface_2)
	
	for i: int in len(surface_array[Mesh.ARRAY_VERTEX]):
		var norm: Vector3 = surface_array[Mesh.ARRAY_VERTEX][i].normalized()
		surface_array[Mesh.ARRAY_VERTEX][i] = norm * rad
	# WHY DOESNT THIS WORK?
		normals.append(norm)
	surface_array[Mesh.ARRAY_NORMAL] = normals 
	
	return surface_array
	
	
static func rotate_mesh_array(surf: Array, axis: Vector3, degrees: float) -> void:
	var vertices: PackedVector3Array = PackedVector3Array()
	for vertex: Vector3 in surf[Mesh.ARRAY_VERTEX]:
		vertices.append(vertex.rotated(axis, deg_to_rad(degrees)))
	surf[Mesh.ARRAY_VERTEX] = vertices
	
	
static func boolean_mesh_arrays(surf_1: Array, surf_2: Array) -> void:
	var indices: PackedInt32Array = PackedInt32Array()
	for index: int in surf_1[Mesh.ARRAY_INDEX]:
		indices.append(index + len(surf_1[Mesh.ARRAY_VERTEX]))
	surf_1[Mesh.ARRAY_VERTEX].append_array(surf_2[Mesh.ARRAY_VERTEX])
	surf_1[Mesh.ARRAY_INDEX].append_array(indices)
