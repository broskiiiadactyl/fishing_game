extends Node3D

var difficulty : float = 1.0

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
	pass

func _physics_process(_delta: float) -> void:
	track_marker()

func init_target() -> void:
	randomize_target()

func randomize_target() -> void:
	var L : float = randf_range(boundL, boundR - difficulty)
	var R : float = randf_range(L + difficulty, boundR)
	var width : float = (R - L) / 2
	
	target_coll.shape.size.x = width
	target_coll.global_position.x = L + width
	target_mesh.mesh.size.x = width
	target_mesh.global_position.x = L + width

func track_marker() -> void:
	arrow.global_position.x = (get_viewport().get_mouse_position().x * 0.006077) - 3.5
	print(arrow.global_position.x)
	pass

func check_target() -> bool:
	return arrow_area.overlaps_body(target)
