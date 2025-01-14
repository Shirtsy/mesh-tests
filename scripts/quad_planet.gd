class_name QuadPlanet
extends MeshInstance3D


@export var radius: float = 1.0
@export var marker: Node3D
@export var noise: Noise

@export var lod_distances: Array[float]


func _ready() -> void:
	mesh = generate_mesh(radius, marker.position, lod_distances, noise)
	print("Mesh Vert Count: ", mesh.surface_get_array_len(Mesh.ARRAY_VERTEX))
	
	
func _process(_delta: float) -> void:
	#mesh = generate_mesh(radius, marker.position, lod_distances, noise)
	pass


#region Static functions
static func generate_mesh(rad: float, marker_pos: Vector3, lod_dist: Array[float], noise: Noise) -> Mesh:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for vert: Vector3 in generate_verts(rad, marker_pos, lod_dist, noise):
		st.set_smooth_group(-1)
		st.add_vertex(vert)
	st.index()
	st.generate_normals()
	return st.commit()


static func generate_verts(rad: float, marker_pos: Vector3, lod_dist: Array[float], noise: Noise) -> PackedVector3Array:
	var verts: PackedVector3Array = PackedVector3Array()
	var quads: Array[Array] = []
	
	var directions: Array[Vector3] = [
		Vector3.UP,
		Vector3.DOWN,
		Vector3.LEFT,
		Vector3.RIGHT,
		Vector3.FORWARD,
		Vector3.BACK
	]
	for dir: Vector3 in directions:
		var plane: Array[Vector3]
		# Turn this into an array of quads instead of a quad and then have a 
		# new quads array that leaf nodes can be recursively added to while passing
		# all the branch nodes to next loop
		plane.assign(generate_cube_face(dir).map(
					func(x: Vector3) -> Vector3: return x.normalized() * rad
			))
		quads.append_array(subdivide_face(marker_pos, lod_dist[0], plane))
	
	# Append quads as two triangles
	for quad: Array[Vector3] in quads:
		verts.append_array(PackedVector3Array([
			quad[0], quad[1], quad[2],
			quad[2], quad[3], quad[0]
		]))
	return verts


static func subdivide_face(marker_pos: Vector3, dist: float, face: Array[Vector3]) -> Array[Array]:
	if any_within_distance(marker_pos, dist, face):
		var new_verts: Array[Vector3] = [
			(face[0] + face[1]) / 2,
			(face[1] + face[2]) / 2,
			(face[2] + face[3]) / 2,
			(face[3] + face[0]) / 2,
			face.reduce(func(accum: Vector3, x: Vector3) -> Vector3: return accum + x, Vector3.ZERO) / 4
		]
		return [
			[face[0], new_verts[0], new_verts[4], new_verts[3]],
			[face[1], new_verts[1], new_verts[4], new_verts[0]],
			[face[2], new_verts[2], new_verts[4], new_verts[1]],
			[face[3], new_verts[3], new_verts[4], new_verts[2]]
		]
	else:
		return [face]


static func generate_cube_face(normal: Vector3) -> Array[Vector3]:
	# Normalize the input vector to ensure we're working with a unit vector
	normal = normal.normalized()
	# Find a vector perpendicular to our normal vector
	# We can do this by finding the cross product with any vector not parallel to normal
	# Using UP vector (0,1,0) works in most cases, but we need a fallback
	var right: Vector3
	if abs(normal.dot(Vector3.UP)) < 0.999:
		right = normal.cross(Vector3.UP).normalized()
	else:
		# If normal is parallel to UP, use FORWARD instead
		right = normal.cross(Vector3.FORWARD).normalized()
	# Get the up vector for our face by crossing normal with right
	# This ensures our vectors are perfectly perpendicular
	var up: Vector3 = normal.cross(right)
	# Now we can construct our four corners
	# The face will be centered at normal * 0.5 (half a unit from center)
	var center: Vector3 = normal * 0.5
	# Create the four corners by adding and subtracting right and up vectors
	var corners: Array[Vector3] = []
	corners.append(center + right * 0.5 + up * 0.5)  # Top-right
	corners.append(center + right * 0.5 - up * 0.5)  # Bottom-right
	corners.append(center - right * 0.5 - up * 0.5)  # Bottom-left
	corners.append(center - right * 0.5 + up * 0.5)  # Top-left
	return corners


## Returns [code]true[/code] if [param pos] is within [param dist] of any
## element in [param points].
static func any_within_distance(pos: Vector3, dist: float, points: Array[Vector3]) -> bool:
	return points.any(
			func(x: Vector3) -> bool:
				return true if pos.distance_squared_to(x) < (dist ** 2) else false
	)
#endregion
