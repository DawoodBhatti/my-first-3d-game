extends Node3D

@onready var gamefloor: CSGBox3D = %Floor

@export var terrain_scene: PackedScene
@export var instance_count: int = 1
@export var terrain_width: float = 0
@export var terrain_depth: float = 0

# Color property with setter logic and backing variable to avoid recursion
var _forcefield_colour: Color = Color(0.0, 0.6, 1.0, 1.0)
@export var forcefield_colour: Color = Color(0.0, 0.6, 1.0, 1.0):
	get: return _forcefield_colour
	set(value):
		if _forcefield_colour != value:
			_forcefield_colour = value
			update_forcefield(value)

var rng = RandomNumberGenerator.new()
var shader_material = ShaderMaterial.new()
var terrain_instances: Array = []


func update_forcefield(value: Color):
	
	for terrain in terrain_instances:
		
		# Don't update shader till mesh has initialised
		if terrain.has_node("Mesh") and terrain.get_node("Mesh").mesh != null:
			print(forcefield_colour)
			terrain.get_node("Mesh").get_active_material(0).set_shader_parameter("glow_color", value)


# Called when the node is added to the scene; scales terrain to floor size
func _ready():
	terrain_width = gamefloor.size[0]
	terrain_depth = gamefloor.size[2]
	
	# Set color at runtime
	forcefield_colour = _forcefield_colour 
	
	generate_central_dome()


# Use this to generate lots of structures placed according to some rules
func generate_terrain_procedurally():
	if not terrain_scene:
		push_error("No terrain scene assigned.")
		return

	var root = $TerrainRoot

	for i in range(instance_count):
		rng.randomize()
		var instance = terrain_scene.instantiate()

		var x = rng.randf_range(-terrain_width / 2, terrain_width / 2)
		var z = rng.randf_range(-terrain_depth / 2, terrain_depth / 2)
		instance.position = Vector3(x, 0, z)

		terrain_instances.append(instance)
		root.add_child(instance)


# Manually generate large central dome with forcefield-like appearance
func generate_central_dome():
	if not terrain_scene:
		push_error("No terrain scene assigned.")
		return

	var root = $TerrainRoot
	var instance = terrain_scene.instantiate()
	instance.position = Vector3(0, 0, 0)

	terrain_instances.append(instance)
	root.add_child(instance)

	shader_material.shader = load("res://levels/structures/forcefield.gdshader")
	shader_material.set_shader_parameter("glow_color", forcefield_colour)

	if instance.has_node("Mesh"):
		var mesh_node = instance.get_node("Mesh")
		if mesh_node.mesh and mesh_node.mesh.get_surface_count() > 0:
			mesh_node.set_surface_override_material(0, shader_material)
