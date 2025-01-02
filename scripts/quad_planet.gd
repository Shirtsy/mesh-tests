class_name QuadPlanet
extends MeshInstance3D


@export var radius: float = 1.0
@export var marker: Node3D

@export var min_distance: float = 10.0
@export var max_distance: float = 100.0
@export var levels: int = 4


func _ready() -> void:
	pass
	
	
func _process(_delta: float) -> void:
	pass


#region Static functions
static func generate_surface_array(
		marker_pos: Vector3,
		min: float,
		max: float,
		levels: int
) -> Array[Array]:
	var surface_array: Array[Array] = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	surface_array[Mesh.ARRAY_NORMAL] = PackedVector3Array()
	surface_array[Mesh.ARRAY_INDEX] = PackedInt32Array()
	var vertices: PackedVector3Array = surface_array[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = surface_array[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = surface_array[Mesh.ARRAY_INDEX]
	
	
	
	return surface_array
#endregion
