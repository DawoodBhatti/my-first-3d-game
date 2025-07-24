extends Node3D

@export var dust_particle_scene: PackedScene  # Your GPUParticles3D dust scene

const TILE_SIZE := 100.0                      # Each emission box is 100x100x100
const FLOOR_SIZE := 1000.0                    # Your terrain size
const GRID_RES := int(FLOOR_SIZE / TILE_SIZE) # Number of emitters in one axis
const HEIGHT_OFFSET := 10.0                   # Elevate particles slightly

func _ready():
	var half_floor := FLOOR_SIZE / 2.0
	for x in GRID_RES:
		for z in GRID_RES:
			var emitter = dust_particle_scene.instantiate()
			add_child(emitter)

			var pos_x := -half_floor + x * TILE_SIZE + TILE_SIZE / 2.0
			var pos_z := -half_floor + z * TILE_SIZE + TILE_SIZE / 2.0
			var spawn_pos := Vector3(pos_x, HEIGHT_OFFSET, pos_z)

			emitter.global_transform.origin = spawn_pos
