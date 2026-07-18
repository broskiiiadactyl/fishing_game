extends Node3D

var vis := false
var playing := false
var score : int = 0
var fish : int = 0
var difficulty : float = 1.0
var life : int = 3

@onready var bobber := %Fishbox

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
@onready var arrow_mesh : Node3D = %bobby
@onready var arrow_area : Area3D = %ArrowArea
@onready var arrow_check : Marker3D = %ArrowBoundCheck

@onready var intro : Label = %Intro

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bobber.visible = not vis
	intro.visible = not vis
	print(boundL, "\n", boundR)

func _physics_process(_delta: float) -> void:
	#print(arrow_check.global_position.x)
	if vis and playing:
		track_marker()
	
	if life <= 0:
		#emit signal to main that game is over
		pass

#when left mouse button is pressed
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		if check_target():
			#emit signal to main to start fishbox and pause bobber
			randomize_target()
		else:
			lose_life()
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

func track_marker() -> void:
	#code to track mouse position and move marker
	#only if playing is true
	pass

func check_target() -> bool:
	#return arrow_area.overlaps_body(target)
	return true

func add_fish() -> void:
	fish += 1
	%FishSpawner.spawn_count = 1
	%FishSpawner.spawn_objects()
	%FishSpawner.global_position.y += .25

func lose_life() -> void:
	#lose a life point on miss
	pass

func final_score() -> void:
	#display final score
	pass

func reset() -> void:
	#flip vis to false
	#clear score
	#clear fish
	pass
