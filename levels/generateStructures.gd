extends Node3D

@export var structure_scene: PackedScene
@export var count: int = 30
@export var spread: float = 500
@export var player: Node3D  


func _ready():
	randomize()
	for i in count:
		var structure = structure_scene.instantiate()
		
		var x = randf_range(-spread, spread)
		var z = randf_range(-spread, spread)
		@warning_ignore("shadowed_variable_base_class")
		var position = Vector3(x, 0, z)

		# Skip if too close to player
		if player and position.distance_to(player.global_transform.origin) < 250.0:
			continue  # try again next loop iteration
		
		# Place the structure
		structure.transform.origin = position

		# Random size and height
		structure.size = randf_range(10.0, 80.0)
		structure.height = randf_range(10.0, 80.0)

		add_child(structure)
