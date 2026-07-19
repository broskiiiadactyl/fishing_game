extends Node3D

var fish : int = 0
var difficulty : float = 1.0
var direction : float = 1.0
var speed_mult : float = 0.05

@onready var counter := %Counter

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
@onready var arrow_start : Vector3 = arrow.global_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	#print(arrow_check.global_position.x)
	if visible:
		move_marker()
		check_marker_bounds()

func init_target(diff : float, spd : float) -> void:
	arrow.global_position = arrow_start
	difficulty = diff
	speed_mult = spd
	randomize_target()

func randomize_target() -> void:
	var diff : float = 1/difficulty
	var L : float = randf_range(boundL, boundR - (diff*2))
	#var R : float = randf_range(L + diff, boundR)
	#var width : float = (R - L) / 2
	var width := diff
	
	#print("width: ", width)
	
	target_coll.shape.size.x = width
	target_coll.global_position.x = L + width
	target_mesh.mesh.size.x = width
	target_mesh.global_position.x = L + width

func move_marker() -> void:
	arrow.global_position.x += direction * speed_mult

func check_marker_bounds() -> void:
	if arrow_check.global_position.x <= boundL:
		#print("pos")
		direction = 1
	elif arrow_check.global_position.x >= boundR:
		#print("neg")
		direction = -1

func check_target() -> bool:
	return arrow_area.overlaps_body(target)

func add_fish() -> void:
	#emit signal to add to fish counter
	pass

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
