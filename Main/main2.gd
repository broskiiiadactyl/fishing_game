extends Node3D

var vis := false
var playing := false
var score : int = 0
var fish : int = 0
var difficulty : float = 1.0
var direction : float = 1.0
var speed_mult : float = 0.01

@onready var target : StaticBody3D = %Target
@onready var target_coll : CollisionShape3D = %TargetColl
@onready var target_mesh : MeshInstance3D = %TargetMesh
@onready var target_check : Marker3D = %TargetBoundCheck

@onready var target_area : MeshInstance3D = %TargetBoundBox
@onready var target_area_origin : Vector3 = target_area.global_position
@onready var boundL : float = target_area_origin.x - (target_area.get_aabb().size.x / 2) + 0.1
@onready var boundR : float = target_area_origin.x + (target_area.get_aabb().size.x / 2) - 0.1

@onready var arrow : StaticBody3D = %Arrow
@onready var arrow_coll : CollisionShape3D = %ArrowColl
@onready var arrow_mesh : MeshInstance3D = %ArrowMesh
@onready var arrow_area : Area3D = %ArrowArea
@onready var arrow_check : Marker3D = %ArrowBoundCheck

@onready var fishbox : Node3D = %FishBox

@onready var intro : Label = %Intro

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fishbox.visible = vis
	intro.visible = not vis
	print(boundL, "\n", boundR)

func _physics_process(_delta: float) -> void:
	#print(arrow_check.global_position.x)
	if vis and playing:
		move_marker()
		check_marker_bounds()

#when left mouse button is pressed
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		if not vis:
			init_target()
			intro.visible = not vis
			fishbox.visible = vis
		else:
			if check_target():
				add_fish()
				randomize_target()
			else:
				playing = false
				tally_score()
	elif event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()

func init_target() -> void:
	randomize_target()
	vis = true
	playing = true

func randomize_target() -> void:
	var L : float = randf_range(boundL, boundR - difficulty)
	var R : float = randf_range(L + difficulty, boundR)
	var width : float = (R - L) / 2
	
	target_coll.shape.size.x = width
	target_coll.global_position.x = L + width
	target_mesh.mesh.size.x = width
	target_mesh.global_position.x = L + width

func move_marker() -> void:
	arrow.global_position.x += direction * speed_mult

func check_marker_bounds() -> void:
	if arrow_check.global_position.x <= boundL:
		print("pos")
		direction = 1
	elif arrow_check.global_position.x >= boundR:
		print("neg")
		direction = -1

func check_target() -> bool:
	return arrow_area.overlaps_body(target)

func add_fish() -> void:
	fish += 1
	%FishSpawner.spawn_count = 1
	%FishSpawner.spawn_objects()
	%FishSpawner.global_position.y += .5

func tally_score() -> void:
	#take some score amount and multiply it by number of successes
	#or however we decide to do that
	pass

func final_score() -> void:
	#display final score
	pass

func reset() -> void:
	#flip vis to false
	#clear score
	#clear fish
	pass
