extends StaticBody3D

@export var size: float = 200.0
@export var height: float = 200.0

func _ready():
	generate_pyramid()

func generate_pyramid():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var apex = Vector3(0, height, 0)
	var base = [
		Vector3(-size, 0, -size),
		Vector3(size, 0, -size),
		Vector3(size, 0, size),
		Vector3(-size, 0, size)
	]

	# Base
	st.add_vertex(base[0])
	st.add_vertex(base[1])
	st.add_vertex(base[2])
	st.add_vertex(base[2])
	st.add_vertex(base[3])
	st.add_vertex(base[0])

	# Sides
	for i in range(4):
		st.add_vertex(base[i])
		st.add_vertex(base[(i + 1) % 4])
		st.add_vertex(apex)

	var mesh = st.commit()

	# Assign mesh
	$Mesh.mesh = mesh

	# Add material
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.6, 0.3)
	$Mesh.set_surface_override_material(0, mat)
	$Mesh.transform.origin = Vector3.ZERO

	# Generate collision
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(mesh.get_faces())

	var collider = CollisionShape3D.new()
	collider.name = "CollisionShape3D"
	collider.shape = shape
	add_child(collider)
