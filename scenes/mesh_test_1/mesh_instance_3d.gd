extends MeshInstance3D

@export var rings = 50:
	set(v):
		rings = v
		#update()
@export var radial_segments = 50:
	set(v):
		radial_segments = v
		#update()
@export var radius = 1.0:
	set(v):
		radius = v
		#update()
@export var freq = 0.1:
	set(v):
		freq = v
		#update()
@export var noise_scale = 0.5:
	set(v):
		noise_scale = v
		#update()
@export var marker: Node3D

var fnl = FastNoiseLite.new()
var mdt = MeshDataTool.new()

func _process(_delta: float) -> void:
	mesh.clear_surfaces()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()

	var thisrow = 0
	var prevrow = 0
	var point = 0

	# Loop over rings.
	for i in range(rings + 1):
		var v = float(i) / rings
		var w = sin(PI * v)
		var y = cos(PI * v)

		# Loop over segments in ring.
		for j in range(radial_segments + 1):
			var u = float(j) / radial_segments
			var x = sin(u * PI * 2.0)
			var z = cos(u * PI * 2.0)
			var vert = Vector3(x * radius * w, y * radius, z * radius * w)
			if vert.distance_to(marker.position) > 1:
				verts.append(vert)
				normals.append(vert.normalized())
				uvs.append(Vector2(u, v))
				point += 1

			# Create triangles in ring using indices.
			if i > 0 and j > 0:
				indices.append(prevrow + j - 1)
				indices.append(prevrow + j)
				indices.append(thisrow + j - 1)

				indices.append(prevrow + j)
				indices.append(thisrow + j)
				indices.append(thisrow + j - 1)

		prevrow = thisrow
		thisrow = point

	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	mdt.create_from_surface(mesh, 0)
	
	fnl.frequency = freq
	
	for i in range(mdt.get_vertex_count()):
		var vert = mdt.get_vertex(i)
		vert = vert * (fnl.get_noise_3dv(vert) * noise_scale + 0.75)
		mdt.set_vertex(i, vert)
		
	mesh.clear_surfaces() # Deletes all of the mesh's surfaces.
	mdt.commit_to_surface(mesh)
