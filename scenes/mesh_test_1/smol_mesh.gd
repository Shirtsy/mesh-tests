class_name SmolMesh
extends MeshInstance3D

@export var threading: bool = true
@export var radius: float = 1.0
@export var subdivisions: int = 1

@onready var thread: Thread = Thread.new()
@onready var tracker: Label = $/root/MeshTest1/CanvasLayer/Tracker

var surface_array: Array = []
var counter: float = 0.0


func _ready() -> void:
	mesh = ArrayMesh.new()
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array = generate_mesh_array(radius, subdivisions)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)


func _process(delta: float) -> void:
	if threading:
		if not thread.is_started():
			thread.start(generate_mesh_array.bind(radius, subdivisions))
		elif not thread.is_alive():
			surface_array = thread.wait_to_finish()
			counter = 0
	else:
		surface_array = generate_mesh_array(radius, subdivisions)
		counter = 0
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	counter += delta
	update_ui()
	
	
func update_ui() -> void:
	threading = $/root/MeshTest1/CanvasLayer/ThreadButton.button_pressed
	tracker.text = "FPS: " + str(Engine.get_frames_per_second()) \
			+ "\n" + "UPS: " + str(snapped(1 / counter, 1)) \
			+ "\n" + "Verts: " + str(len(surface_array[Mesh.ARRAY_VERTEX]))
	
	
static func generate_mesh_array(rad: float, subdiv: int) -> Array:
	var surf_array: Array = []
	surf_array.resize(Mesh.ARRAY_MAX)
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
			
	surf_array[Mesh.ARRAY_VERTEX] = vertices
	surf_array[Mesh.ARRAY_INDEX] = indices
	
	# Fix this to be correct
	var surface_2: Array = surf_array.duplicate(true)
	rotate_mesh_array(surface_2, Vector3.LEFT, 90.0)
	#boolean_mesh_arrays(surf_array, surface_2)
	rotate_mesh_array(surface_2, Vector3.LEFT, 90.0)
	boolean_mesh_arrays(surf_array, surface_2)
	surface_2 = surf_array.duplicate(true)
	rotate_mesh_array(surface_2, Vector3.UP, 90.0)
	boolean_mesh_arrays(surf_array, surface_2)
	rotate_mesh_array(surface_2, Vector3.FORWARD, 90.0)
	boolean_mesh_arrays(surf_array, surface_2)
	
	for i: int in len(surf_array[Mesh.ARRAY_VERTEX]):
		var norm: Vector3 = surf_array[Mesh.ARRAY_VERTEX][i].normalized()
		surf_array[Mesh.ARRAY_VERTEX][i] = norm * rad
		normals.append(norm)
	surf_array[Mesh.ARRAY_NORMAL] = normals
	
	return surf_array
	
	
static func rotate_mesh_array(surf: Array, axis: Vector3, degrees: float) -> void:
	var vertices: PackedVector3Array = PackedVector3Array()
	for vertex: Vector3 in surf[Mesh.ARRAY_VERTEX]:
		vertices.append(vertex.rotated(axis, deg_to_rad(degrees)))
	surf[Mesh.ARRAY_VERTEX] = vertices
	
	
static func boolean_mesh_arrays(surf_1: Array, surf_2: Array) -> void:
	var indices: PackedInt32Array = PackedInt32Array()
	for index: int in surf_2[Mesh.ARRAY_INDEX]:
		indices.append(index + len(surf_1[Mesh.ARRAY_VERTEX]))
	surf_1[Mesh.ARRAY_VERTEX].append_array(surf_2[Mesh.ARRAY_VERTEX])
	surf_1[Mesh.ARRAY_INDEX].append_array(indices)
