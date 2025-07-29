@tool
extends Node3D

@onready var floor: CSGBox3D = %Floor

@export var terrain_scene: PackedScene
@export var instance_count: int = 1
@export var terrain_width: float = 0
@export var terrain_depth: float = 0
@export var forcefield_colour: Color = Color(0.0, 0.6, 1.0):
	set(value) : update_forcefield(value)
	
var rng = RandomNumberGenerator.new()
var shader_material = ShaderMaterial.new()
var terrain_instances : Array = [] 

func update_forcefield(value: Color):
	print("updating forcefield")
	print("value: ", value)
	for terrain in terrain_instances:
		print(terrain.name)
		if terrain.has_node("Mesh"):
			print("found mesh")
			
		if terrain.get_node("Mesh").get_surface_override_material(0) is ShaderMaterial:
			print("found shader material")
			
		if terrain.has_node("Mesh") and terrain.get_node("Mesh").get_surface_override_material(0):
			print(forcefield_colour)
			terrain.get_node("Mesh").get_active_material(0).set_shader_parameter("glow_color", value)




func _ready():
	#scale to size of floor
	terrain_width = floor.size[0]
	terrain_depth = floor.size[2]

	generate_central_dome()


#use this to generate lots of structures placed according to some rules
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


#manually generate large central dome with forcefield like appearance
func generate_central_dome():
	
	if not terrain_scene:
		push_error("No terrain scene assigned.")
		return

	var root = $TerrainRoot
	
	var instance = terrain_scene.instantiate()
	var x = 0
	var z = 0
	instance.position = Vector3(x, 0, z)
	
	terrain_instances.append(instance)
	root.add_child(instance)
	
	shader_material.shader = load("res://levels/structures/forcefield.gdshader")
	shader_material.set_shader_parameter("glow_color", forcefield_colour)
	instance.get_node("Mesh").set_surface_override_material(0, shader_material)


	
