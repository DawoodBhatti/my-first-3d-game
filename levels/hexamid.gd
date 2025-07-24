# File: res://HexDome.gd
# Builds a geodesic‐style dome of hexagons with proper collision.
# No ternary operators; uses only if…else. Godot 4.4 compatible.

extends Node3D

#───────────────────────────────────────────
const PI  := 3.141592653589793
const TAU := PI * 2.0
#───────────────────────────────────────────

@export var size: float         = 20.0   # hex center→corner
@export var height: float       = 100.0  # dome radius (also collision bounds)
@export var ring_count: int     = 8      # number of rings (or Fibonacci points)
@export var use_fibonacci: bool = false  # switch between ring vs. Fibonacci

func _ready():
	build_hex_dome()


func build_hex_dome():
	# 1) Build one flat hexagon mesh
	var hex_mesh: ArrayMesh = _build_hex_mesh()

	# 2) Prepare MultiMesh for instancing
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = hex_mesh

	# 3) Decide total instances
	var total_instances: int
	if use_fibonacci:
		total_instances = ring_count
	else:
		total_instances = 1 + 3 * ring_count * (ring_count + 1)
	mm.instance_count = total_instances

	# 4) Create and add the MultiMeshInstance3D
	var mm_instance := MultiMeshInstance3D.new()
	mm_instance.multimesh = mm
	add_child(mm_instance)

	# 5) Compute transforms on the CPU
	var transforms := []
	transforms.resize(total_instances)
	if use_fibonacci:
		_compute_fibonacci_transforms(transforms, total_instances)
	else:
		_compute_ring_transforms(transforms)
	for i in range(total_instances):
		mm.set_instance_transform(i, transforms[i])

	# 6) Bake collision into one ConcavePolygonShape3D
	_generate_collision(hex_mesh, transforms)


func _build_hex_mesh() -> ArrayMesh:
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()

	for i in range(6):
		var a_ang = deg_to_rad(60 * i)
		var b_ang = deg_to_rad(60 * (i + 1))
		var v0 = Vector3.ZERO
		var v1 = Vector3(cos(a_ang) * size, 0.0, sin(a_ang) * size)
		var v2 = Vector3(cos(b_ang) * size, 0.0, sin(b_ang) * size)

		verts.append(v0); verts.append(v1); verts.append(v2)
		norms.append(Vector3.UP); norms.append(Vector3.UP); norms.append(Vector3.UP)

	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = verts
	arrays[ArrayMesh.ARRAY_NORMAL] = norms

	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _compute_ring_transforms(out_transforms: Array):
	var idx: int = 0
	for r in range(ring_count + 1):
		var count: int
		if r == 0:
			count = 1
		else:
			count = r * 6

		for i in range(count):
			var t = float(r) / float(ring_count)
			var lat = (1.0 - t) * PI * 0.5
			var ring_r = cos(lat) * height
			var y = sin(lat) * height

			var ang: float
			if r == 0:
				ang = 0.0
			else:
				ang = TAU * float(i) / float(count)

			var center = Vector3(ring_r * cos(ang), y, ring_r * sin(ang))

			var normal = center.normalized()
			var axis = Vector3.UP.cross(normal)
			var dp = clamp(Vector3.UP.dot(normal), -1.0, 1.0)
			var rot_angle = acos(dp)

			var basis: Basis = Basis()
			if axis.length() > 0.001:
				basis = Basis(axis.normalized(), rot_angle)

			out_transforms[idx] = Transform3D(basis, center)
			idx += 1


func _compute_fibonacci_transforms(out_transforms: Array, count: int):
	var golden_angle = PI * (3.0 - sqrt(5.0))
	var idx: int = 0
	var i:   int = 0
	while idx < count:
		var theta = float(i) * golden_angle
		var t     = float(i + 0.5) / float(count)
		var y     = t
		var r_val = sqrt(1.0 - y * y)
		var x     = cos(theta) * r_val
		var z     = sin(theta) * r_val

		var center = Vector3(x, y, z) * height

		var normal = center.normalized()
		var axis   = Vector3.UP.cross(normal)
		var dp     = clamp(Vector3.UP.dot(normal), -1.0, 1.0)
		var rot_angle = acos(dp)

		var basis: Basis = Basis()
		if axis.length() > 0.001:
			basis = Basis(axis.normalized(), rot_angle)

		out_transforms[idx] = Transform3D(basis, center)
		idx += 1
		i   += 1


func _generate_collision(mesh: ArrayMesh, transforms: Array):
	# 1) Gather all transformed vertices
	var base_verts = mesh.surface_get_arrays(0)[ArrayMesh.ARRAY_VERTEX] \
		as PackedVector3Array
	var faces := PackedVector3Array()
	for tform in transforms:
		for j in range(0, base_verts.size(), 3):
			faces.append(tform * base_verts[j + 0])
			faces.append(tform * base_verts[j + 1])
			faces.append(tform * base_verts[j + 2])

	# 2) Build the ConcavePolygonShape3D via set_faces()
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(faces)

	# 3) Attach to a StaticBody3D
	var body = StaticBody3D.new()
	add_child(body)
	var col = CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)
