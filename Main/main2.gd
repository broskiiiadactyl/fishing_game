extends Node3D

var vis := false
var score : int = 0
var fish : int = 0
var difficulty : float = 1.0
var direction : float = 1.0
var speed_mult : float = 0.05
var count : int = 3
var done = false

enum gamestate {START, BOBBER, FISHING, LOSE, SCORE}
var active_state = gamestate.START

@onready var fishbox := %Fishbox
@onready var bobber := %Bobber
@onready var spawner := %FishSpawner
@onready var timer := %LevelTime

@onready var intro : Label = %Intro
@onready var phrases : Label = %Phrases
@onready var score_lab : Label = %ScoreLabel
@onready var score_num : Label = %ScoreNum
@onready var timer_lab : Label = %TimerLabel
@onready var timeout_lab : Label = %Timeout

var small_pool : Array[String] = ["Normal"]
var med_pool : Array[String] = ["Gift"]
var big_pool : Array[String] = ["Wizard", "Knight"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fishbox.visible = vis
	intro.visible = not vis
	score_lab.visible = false
	score_num.visible = false
	timer_lab.visible = false
	timeout_lab.visible = false

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
				count = 3
				vis = true
			if count <= 0:
				add_fish(difficulty)
				vis = false
				set_active(gamestate.BOBBER)
			fishbox.counter.text = str(count)
		gamestate.LOSE:
			pass
		gamestate.SCORE:
			if not vis:
				#start animation of character
				#turn on coll detection?
				vis = true
				pass
			#animation of character climbing
			#move camera until no coll?
	
	if timer_lab.visible == true:
		timer_lab.text = str(int(timer.time_left))

func set_active(state) -> void:
	match state:
		gamestate.START:
			active_state = gamestate.START
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			fishbox.visible = false
			bobber.visible = false
			intro.visible = true
			score_lab.visible = false
			score_num.visible = false
			timer_lab.visible = false
			timeout_lab.visible = false
		gamestate.BOBBER:
			active_state = gamestate.BOBBER
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_ALWAYS
			bobber.arrow.visible = true
			fishbox.visible = false
			bobber.visible = true
			intro.visible = false
			score_lab.visible = true
			score_num.visible = true
			timer_lab.visible = true
			timeout_lab.visible = false
		gamestate.FISHING:
			active_state = gamestate.FISHING
			fishbox.process_mode = Node.PROCESS_MODE_ALWAYS
			bobber.process_mode = Node.PROCESS_MODE_ALWAYS
			bobber.arrow.visible = false
			fishbox.visible = true
			bobber.visible = true
			intro.visible = false
			score_lab.visible = true
			score_num.visible = true
			timer_lab.visible = true
			timeout_lab.visible = false
		gamestate.LOSE:
			active_state = gamestate.LOSE
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			fishbox.visible = false
			bobber.visible = false
			intro.visible = false
			score_lab.visible = true
			score_num.visible = true
			timer_lab.visible = true
			timeout_lab.visible = true
			await get_tree().create_timer(3.0).timeout
			set_active(gamestate.SCORE)
		gamestate.SCORE:
			active_state = gamestate.SCORE
			vis = false
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			fishbox.visible = false
			bobber.visible = false
			intro.visible = false
			score_lab.visible = false
			score_num.visible = false
			timer_lab.visible = false
			timeout_lab.visible = false
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
					set_active(gamestate.FISHING)
					vis = false
			gamestate.FISHING:
				if fishbox.check_target():
					count -= 1
					fishbox.randomize_target()
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
	spawner.spawn_objects(1, size, species)
	spawner.global_position.y += (size * .25)
	
	var caught : String = "Caught " + species + " Fish!"
	play_phrase(caught)

func miss() -> void:
	play_phrase("MISS!")
	set_active(gamestate.BOBBER)

func play_phrase(phrase : String) -> void:
	phrases.text = phrase
	phrases.visible = true
	await get_tree().create_timer(1.0).timeout
	phrases.visible = false

func set_fish(size : float) -> String:
	if size == 1: 
		return small_pool.pick_random()
	elif size == 2:
		return med_pool.pick_random()
	elif size == 3:
		return big_pool.pick_random()
	
	return "ERROR"

func final_score() -> void:
	#display final score
	pass

func reset() -> void:
	#flip vis to false
	#clear score
	#clear fish
	pass


func _on_level_time_timeout() -> void:
	done = true
