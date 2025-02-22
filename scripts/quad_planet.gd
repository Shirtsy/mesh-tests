class_name QuadPlanet
extends MeshInstance3D


signal mesh_updated


@export var collider: CollisionShape3D
@export var radius: float = 1.0
@export var marker: Node3D
@export var lod_distances: Array[float]
@export var noise_mult: float = 1.0
@export var multi_noise: MultiNoise


var thread: Thread = Thread.new()


const DIRECTIONS: Array[Vector3] = [
	Vector3.UP,
	Vector3.DOWN,
	Vector3.LEFT,
	Vector3.RIGHT,
	Vector3.FORWARD,
	Vector3.BACK
]


func _ready() -> void:
	assert(marker, "Marker Node3D not set.")
	assert(multi_noise, "MultiNoise not set.")
	assert(collider, "Collider not set.")
	mesh = generate_mesh(radius, marker.position - position, lod_distances, multi_noise, noise_mult)
	#print("Mesh Vert Count: ", mesh.surface_get_array_len(Mesh.ARRAY_VERTEX))
	
	 
func _process(_delta: float) -> void:
	if not thread.is_started():
		thread.start((
				func(rad: float, marker_pos: Vector3, lod_dist: Array[float], noi: MultiNoise, noi_mult: float) -> Dictionary:
					var surf: Mesh = generate_mesh(rad, marker_pos, lod_dist, noi, noi_mult)
					return {
						surface = surf,
						shape = surf.create_trimesh_shape()
					}
		).bind(radius, marker.position - position, lod_distances, multi_noise, noise_mult))
	elif not thread.is_alive():
		var thread_result: Dictionary = thread.wait_to_finish()
		mesh = thread_result.surface
		collider.shape = thread_result.shape
		mesh_updated.emit()


#region Static functions
static func generate_mesh(
		rad: float,
		marker_pos: Vector3,
		lod_dist: Array[float],
		noi: MultiNoise,
		noi_mult: float
) -> Mesh:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for vert: Vector3 in generate_verts(rad, marker_pos, lod_dist, noi, noi_mult):
		st.set_smooth_group(-1)
		st.add_vertex(vert)
	st.index()
	st.generate_normals()
	return st.commit()


static func generate_verts(
		rad: float,
		marker_pos: Vector3,
		lod_dist: Array[float],
		noi: MultiNoise,
		noi_mult: float
) -> PackedVector3Array:
	var verts: PackedVector3Array = PackedVector3Array()
	var process_quads: Array[Array] = []
	var draw_quads: Array[Array] = []
	
	# Generate cube faces normalized to sphere.
	for dir: Vector3 in DIRECTIONS:
		process_quads.append(generate_cube_face(dir).map(
				func(x: Vector3) -> Vector3:
					return x.normalized() * rad
		))
		
	# Go through all quads. Ones outside LOD ranges are added to draw.
	# All within LOD ranges are added to processing list, are subdivided, then
	# get added back to processing list for next layer. This way only 'leaf'
	# quads get drawn.
	var hypermap: HyperMap = HyperMap.new()
	for dist: float in lod_dist:
		if len(process_quads) == 0:
			#print("Done!")2
			break
		hypermap.start(
				func(quad: Array) -> Array[Array]:
					var typed_quad: Array[Vector3]
					typed_quad.assign(quad)
					if any_within_distance(typed_quad, marker_pos, dist):
						return subdivide_quad(typed_quad, rad)
					else:
						return [typed_quad]
					,
				process_quads
		)
		var processed_quad_lists: Array = hypermap.wait_for_result()
		draw_quads.append_array(flatten(processed_quad_lists.filter(
				func(x: Array) -> bool:
					return len(x) == 1
		)))
		process_quads.assign(flatten(processed_quad_lists.filter(
				func(x: Array) -> bool:
					return len(x) == 4
		)))
	draw_quads.append_array(process_quads)
	
	# Renormalize verts to apply noise to draw_quads
	draw_quads.assign(draw_quads.map(
			func(x: Array) -> Array[Vector3]:
				var new_quad: Array[Vector3] = []
				for vert: Vector3 in x:
					var new_vert: Vector3 = (
							vert.normalized()
							* (rad + noi.get_noise_3dv(vert) * noi_mult)
					)
					new_quad.append(new_vert)
				return new_quad
	))
	
	# Append quads as two triangles.
	for quad: Array[Vector3] in draw_quads:
		verts.append_array(PackedVector3Array([
			quad[0], quad[1], quad[2],
			quad[2], quad[3], quad[0]
		]))
	return verts


static func subdivide_quad(face: Array[Vector3], rad: float) -> Array[Array]:
	var new_verts: Array[Vector3] = [
		(face[0] + face[1]) / 2,
		(face[1] + face[2]) / 2,
		(face[2] + face[3]) / 2,
		(face[3] + face[0]) / 2,
		face.reduce(
				func(accum: Vector3, x: Vector3) -> Vector3:
					return accum + x, Vector3.ZERO
		) / 4
	]
	new_verts.assign(new_verts.map(
				func(x: Vector3) -> Vector3:
					return x.normalized() * rad
	))
	return [
		[face[0], new_verts[0], new_verts[4], new_verts[3]],
		[new_verts[0], face[1], new_verts[1], new_verts[4]],
		[face[2], new_verts[2], new_verts[4], new_verts[1]],
		[new_verts[2], face[3], new_verts[3], new_verts[4]]
	]


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
	var corners: Array[Vector3] = [
		center + right * 0.5 + up * 0.5,  # Top-right
		center + right * 0.5 - up * 0.5,  # Bottom-right
		center - right * 0.5 - up * 0.5,  # Bottom-left
		center - right * 0.5 + up * 0.5  # Top-left
	]
	return corners


## Returns [code]true[/code] if [param pos] is within [param dist] of any
## element in [param points].
static func any_within_distance(points: Array[Vector3], pos: Vector3, dist: float) -> bool:
	return points.any(
			func(x: Vector3) -> bool:
				return true if pos.distance_squared_to(x) < (dist ** 2) else false
	)
	

## Processes [param arr] with [param function]. Returns [Array]. Index [code]0[/code] is false values.
## Index [code]1[/code] is true values.
static func sort_array(function: Callable, arr: Array) -> Array[Array]:
	var falsey: Array = []
	var truthy: Array = []
	for item: Variant in arr:
		if function.call(item):
			truthy.append(item)
		else:
			falsey.append(item)
	return [falsey, truthy]
	

static func flatten(arr: Array) -> Array:
	var new_arr: Array = []
	for a: Array in arr:
		for item: Variant in a:
			new_arr.append(item)
	return new_arr
#endregion
