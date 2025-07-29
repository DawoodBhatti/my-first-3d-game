extends Node3D

@export var radius: float = 100.0
@export var latitude_segments: int = 16
@export var longitude_segments: int = 32

func _ready():
	generate_semisphere()

func generate_semisphere():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for lat in range(latitude_segments):
		var theta1 = PI * lat / latitude_segments / 2
		var theta2 = PI * (lat + 1) / latitude_segments / 2

		for lon in range(longitude_segments):
			var phi1 = TAU * lon / longitude_segments
			var phi2 = TAU * (lon + 1) / longitude_segments

			var p1 = _spherical_to_cartesian(theta1, phi1)
			var p2 = _spherical_to_cartesian(theta2, phi1)
			var p3 = _spherical_to_cartesian(theta2, phi2)
			var p4 = _spherical_to_cartesian(theta1, phi2)

			st.add_vertex(p1 * radius)
			st.add_vertex(p2 * radius)
			st.add_vertex(p3 * radius)

			st.add_vertex(p1 * radius)
			st.add_vertex(p3 * radius)
			st.add_vertex(p4 * radius)

	var mesh = st.commit()
	$Mesh.mesh = mesh

	# Material
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.8, 0.9)
	$Mesh.set_surface_override_material(0, mat)
	$Mesh.transform.origin = Vector3.ZERO

	# Collision
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(mesh.get_faces())

	var collider = CollisionShape3D.new()
	collider.name = "CollisionShape3D"
	collider.shape = shape
	add_child(collider)

func _spherical_to_cartesian(theta: float, phi: float) -> Vector3:
	var x = sin(theta) * cos(phi)
	var y = cos(theta)
	var z = sin(theta) * sin(phi)
	return Vector3(x, y, z)
