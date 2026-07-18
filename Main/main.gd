extends Node3D

var vis := false
var playing := false
var score : int = 0
var fish : int = 0
var difficulty : float = 40.0
var direction : float = 1.0
var speed_mult : float = 2.0

@onready var target : CollisionShape2D = %TargetColl

@onready var target_area : ColorRect = %TargetArea
@onready var boundL : float = target_area.global_position.x
@onready var boundR : float = boundL + target_area.size.x

@onready var arrow : Sprite2D = %Arrow
@onready var arrow_area : Area2D = %ArrowArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if vis and playing:
		move_marker()
		check_marker_bounds()

#when left mouse button is pressed
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		if not vis:
			init_target()
			%Intro.visible = not vis
			%TargetUI.visible = vis
		else:
			if check_target():
				add_fish()
				randomize_target()
			else:
				playing = false
				tally_score()

func init_target() -> void:
	randomize_target()
	vis = true
	playing = true
	pass

func randomize_target() -> void:
	var L : float = randf_range(boundL, boundR - (difficulty*2))
	var R : float = difficulty
	
	target.shape.size.x = R
	target.global_position.x = L + (target.shape.size.x)
	%ColorRect.size.x = target.shape.size.x
	%ColorRect.global_position.x = target.global_position.x - %ColorRect.size.x

func move_marker() -> void:
	arrow.position.x += direction * speed_mult

func check_marker_bounds() -> void:
	if arrow.position.x <= boundL:
		direction = 1
	elif arrow.position.x >= boundR:
		direction = -1

func check_target() -> bool:
	return arrow_area.get_overlapping_areas().has(%Target)

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
