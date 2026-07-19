extends Node3D

#This is a general spawner
#Spawns objects on load
#Add the scene of whatever you want to spawn in the inspector

@export_group("Spawn Parameters")
@export var spawn_scene: PackedScene = preload("res://functional/fish.tscn")
@export var spawn_count := 5
@export var use_random_offset := false
@export var spawn_range := Vector3(0,0,0)
@export var spawn_timer := 0.0

func _ready() -> void:
	#spawn_objects()
	pass

func spawn_objects(num : int, size : float, type : String) -> void:
	spawn_count = num
	
	if spawn_scene == null:
		push_warning("No scene to spawn. Assign a scene.")
		return
	
	for i in range(spawn_count):
		var x := spawn_range.x
		var y := spawn_range.y
		var z := spawn_range.z
		
		var pos = global_transform.origin
		if use_random_offset:
			pos += Vector3(
				randf_range(-x, x),
				randf_range(-y, y),
				randf_range(-z, z)
			)
			
		if spawn_timer > 0.0:
			await wait(spawn_timer)
			
		var instance := spawn_scene.instantiate()
		#print(instance.name, " spawned at ", pos)
		get_parent().add_child(instance)
		instance.global_position = pos
		instance.rotation.y = self.rotation.y + randf_range(-0.5, 0.5)
		instance.scale *= size
		instance.set_model(type)
		
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
