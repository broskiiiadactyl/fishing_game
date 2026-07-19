extends Node3D

var vis : bool = false
var score : int = 0
var fish : int = 0
var difficulty : float = 1.0
var direction : float = 1.0
var speed_mult : float = 0.05
var count : int = 3
var done : bool = false
var scored : bool = false
var camera_speed : float = 0.05
var minimum : bool = false
var lives : int = 3

enum gamestate {START, BOBBER, FISHING, LOSE, SCORE}
var active_state = gamestate.START

@onready var fishbox := %Fishbox
@onready var bobber := %Bobber
@onready var spawner := %FishSpawner
@onready var timer := %LevelTime
@onready var tally := %Tally
@onready var score_timer := %ScoreTimer
@onready var camera := %Camera3D
@onready var fisher := %Rogue

@onready var intro : Label = %Intro
@onready var phrases : Label3D = %Phrases
@onready var score_lab : Label = %ScoreLabel
@onready var score_num : Label = %ScoreNum
@onready var timer_lab : Label = %TimerLabel
@onready var timeout_lab : Label = %Timeout
@onready var fish_lab : Label = %FishLabel
@onready var fish_num : Label = %FishNum
@onready var reset_lab : Label = %RestartLabel

@onready var camera_start : Vector3 = camera.global_position
@onready var marker := %ShowFish

@onready var feesh := preload("res://functional/fish.tscn")

var small_pool : Array[String] = ["Normal"]
var med_pool : Array[String] = ["Gift", "Truck", "Keys", "Skull"]
var big_pool : Array[String] = ["Wizard", "Knight", "Rich"]

@onready var BGM := %BGM
@onready var catch_sfx := %CatchSFX
@onready var hit := %HitSFX
@onready var miss_sfx := %MissSFX
@onready var timer_sfx := %Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fishbox.visible = vis
	intro.visible = not vis
	score_lab.visible = false
	score_num.visible = false
	timer_lab.visible = false
	timeout_lab.visible = false
	fish_lab.visible = false
	fish_num.visible = false
	reset_lab.visible = false
	
	BGM.play()

func _physics_process(_delta: float) -> void:
	match active_state:
		gamestate.START:
			done = false
		gamestate.BOBBER:
			if done:
				set_active(gamestate.LOSE)
				vis = false
			elif not vis:
				bobber.init_target()
				vis = true
		gamestate.FISHING:
			if not vis:
				fishbox.init_target(difficulty, difficulty/35)
				vis = true
			if count <= 0:
				add_fish(difficulty)
				catch_sfx.play()
				vis = false
				set_active(gamestate.BOBBER)
				fisher.pull()
				await get_tree().create_timer(0.5).timeout
				fisher.hold()
			fishbox.counter.text = str(count)
		gamestate.LOSE:
			pass
		gamestate.SCORE:
			if not vis:
				#start animation of character
				#turn on coll detection?
				#start drumroll?
				vis = true
			if not scored:
				if tally.global_position.y >= 4.0:
					camera.global_position.y += camera_speed
				if tally.global_position.y >= 5.0:
					if fisher.player.current_animation != "Basic/Climb":
						fisher.climb()
					minimum = true
					fisher.global_position = tally.global_position - Vector3(0,2.0,-1.0)
				tally.global_position.y += camera_speed
			else:
				if tally.global_position.y >= 5.0:
					if fisher.player.current_animation != "Basic/Yay":
						fisher.yay()
					fisher.global_position = tally.global_position - Vector3(0,0.25,-0.5)
				else:
					fisher.boo()
				await get_tree().create_timer(2.0).timeout
				score_lab.visible = true
				score_num.visible = true
				fish_lab.visible = true
				fish_num.visible = true
				
				reset_lab.visible = true
	
	if timer_lab.visible == true:
		timer_lab.text = str(int(timer.time_left))
	
	#if lives <= 0:
		#done = true

func set_active(state) -> void:
	match state:
		gamestate.START:
			active_state = gamestate.START
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			tally.process_mode = Node.PROCESS_MODE_DISABLED
			fishbox.visible = false
			bobber.visible = false
			intro.visible = true
			score_lab.visible = false
			score_num.visible = false
			timer_lab.visible = false
			timeout_lab.visible = false
			fish_lab.visible = false
			fish_num.visible = false
		gamestate.BOBBER:
			active_state = gamestate.BOBBER
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_ALWAYS
			tally.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.arrow.visible = true
			fishbox.visible = false
			bobber.visible = true
			intro.visible = false
			score_lab.visible = false
			score_num.visible = false
			timer_lab.visible = true
			timeout_lab.visible = false
			fish_lab.visible = false
			fish_num.visible = false
		gamestate.FISHING:
			active_state = gamestate.FISHING
			fishbox.process_mode = Node.PROCESS_MODE_ALWAYS
			bobber.process_mode = Node.PROCESS_MODE_ALWAYS
			tally.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.arrow.visible = false
			fishbox.visible = true
			bobber.visible = true
			intro.visible = false
			score_lab.visible = false
			score_num.visible = false
			timer_lab.visible = true
			timeout_lab.visible = false
			fish_lab.visible = false
			fish_num.visible = false
		gamestate.LOSE:
			active_state = gamestate.LOSE
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			tally.process_mode = Node.PROCESS_MODE_DISABLED
			fishbox.visible = false
			bobber.visible = false
			intro.visible = false
			score_lab.visible = false
			score_num.visible = false
			timer_lab.visible = true
			timeout_lab.visible = true
			fish_lab.visible = false
			fish_num.visible = false
			timer_sfx.play()
			await get_tree().create_timer(3.0).timeout
			set_active(gamestate.SCORE)
		gamestate.SCORE:
			active_state = gamestate.SCORE
			vis = false
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			tally.process_mode = Node.PROCESS_MODE_ALWAYS
			fishbox.visible = false
			bobber.visible = false
			intro.visible = false
			score_lab.visible = false
			score_num.visible = false
			timer_lab.visible = false
			timeout_lab.visible = false
			fish_lab.visible = false
			fish_num.visible = false
			%Failcheck.start()
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		match active_state:
			gamestate.START:
				#print("start")
				set_active(gamestate.BOBBER)
				timer.start()
			gamestate.BOBBER:
				var check = bobber.check_target()
				if check:
					#print("check: ", check)
					difficulty = check
					count = check
					set_active(gamestate.FISHING)
					vis = false
			gamestate.FISHING:
				if fishbox.check_target():
					count -= 1
					fishbox.randomize_target()
					hit.play()
				else:
					miss()
			gamestate.LOSE:
				pass
			gamestate.SCORE:
				#set some variable to take input to restart (maybe just display "R" to restart)
				pass
	
	elif event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()

func add_fish(size : float) -> void:
	var species : String = set_fish(size)
	fish += 1
	score += int(size)
	score_num.text = str(score)
	fish_num.text = str(fish)
	spawner.spawn_objects(1, size, species)
	spawner.global_position.y += (size * .25)
	
	var caught : String = "Caught " + species + " Fish!"
	play_phrase(caught,species)

func miss() -> void:
	play_phrase("MISS!", "")
	set_active(gamestate.BOBBER)
	lives -= 1
	miss_sfx.play()
	

func play_phrase(phrase : String, species : String) -> void:
	phrases.text = phrase
	var instance := feesh.instantiate()
	
	
	if species != "":
		#print(instance.name, " spawned at ", pos)
		get_parent().add_child(instance)
		instance.global_position = marker.global_position
		instance.rotation = marker.rotation
		#instance.scale *= 0.5
		instance.set_model(species)
	
	phrases.visible = true
	await get_tree().create_timer(1.0).timeout
	phrases.visible = false
	
	if species != "":
		instance.queue_free()

func set_fish(size : float) -> String:
	if size == 1: 
		return small_pool.pick_random()
	elif size == 2:
		return med_pool.pick_random()
	elif size == 3:
		return big_pool.pick_random()
	
	return "ERROR"


func _on_level_time_timeout() -> void:
	done = true


func _on_tally_area_entered(area: Area3D) -> void:
	%Failcheck.stop()
	print("true")
	if area.is_in_group("Fish") and not area.get_parent().counted:
		print("counted")
		fish += 1
		score += area.get_parent().size
		area.get_parent().counted = true


func _on_tally_area_exited(_area: Area3D) -> void:
	if tally.get_overlapping_areas().is_empty():
		scored = true


func _on_failcheck_timeout() -> void:
	scored = true
