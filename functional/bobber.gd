extends Node3D

var difficulty : float = 1.0
var spawner : int = 0
var cull_time : float = 1.5

@onready var spawn_timer : Timer = %SpawnTimer
@onready var cull_timer : Timer = %CullTimer

@onready var target1 : StaticBody3D = %Target1
@onready var target2 : StaticBody3D = %Target2
@onready var target3 : StaticBody3D = %Target3

@onready var target_area : MeshInstance3D = %TargetBoundBox
@onready var target_area_origin : Vector3 = target_area.global_position
@onready var boundL : float = target_area_origin.x - (target_area.get_aabb().size.x / 2) + 0.1
@onready var boundR : float = target_area_origin.x + (target_area.get_aabb().size.x / 2) - 0.1
@onready var target_pos : Vector3 = Vector3(boundR + 3, target_area.global_position.y, target_area.global_position.z)

@onready var arrow : StaticBody3D = %Arrow
@onready var arrow_coll : CollisionShape3D = %ArrowColl
@onready var arrow_mesh : Node3D = %bobby
@onready var arrow_area : Area3D = %ArrowArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target1.visible = false
	target2.visible = false
	target3.visible = false	
	spawner = 0

func _physics_process(delta: float) -> void:
	track_marker()
	
	if target1.on:
		if target1.global_position.x >= target_pos.x:
			print(true)
			cull_fish(target1)
		else:
			target1.global_position.x += target1.difficulty/50
	if target2.on:
		if target2.global_position.x >= target_pos.x:
			cull_fish(target2)
		else:
			target2.global_position.x += target2.difficulty/50
	if target3.on:
		if target3.global_position.x >= target_pos.x:
			cull_fish(target3)
		else:
			target3.global_position.x += target3.difficulty/50

func init_target() -> bool:
	spawn_timer.start()
	spawn_fish(0)
	return true

func spawn_fish(count : int) -> void:
	match count%3:
		0:
			if not target1.on:
				randomize_target(target1, set_difficulty())
			print(1)
		1:
			if not target2.on:
				randomize_target(target2, set_difficulty())
			print(2)
		2:
			if not target3.on:
				randomize_target(target3, set_difficulty())
			print(3)
	spawner += 1

func cull_fish(tar : StaticBody3D) -> void:
	tar.visible = false
	tar.on = false
	tar.process_mode = Node.PROCESS_MODE_DISABLED

func randomize_target(tar : StaticBody3D, width : float) -> void:
	var pos : float = boundL - width 
	
	tar.get_node("TargetColl").shape.size.x = width
	tar.global_position.x = pos
	tar.get_node("TargetMesh").mesh.size.x = width
	
	tar.difficulty = width
	tar.visible = true
	tar.process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().physics_frame
	tar.on = true

func track_marker() -> void:
	arrow.global_position.x = (get_viewport().get_mouse_position().x * 0.006077) - 3.5

func check_target() -> float:
	var bodies = arrow_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("target"):
			return body.difficulty
	return 0.0

func set_difficulty() -> float:
	var roll = randi_range(0, 100)
	
	if roll > 80:
		return 3.0
	elif roll > 50:
		return 2.0
	return 1.0

func stop() -> void:
	cull_fish(target1)
	cull_fish(target2)
	cull_fish(target3)

func _on_spawn_timer_timeout() -> void:
	spawn_fish(spawner)
