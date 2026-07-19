extends Node3D

var vis := false
var score : int = 0
var fish : int = 0
var difficulty : float = 1.0
var direction : float = 1.0
var speed_mult : float = 0.05
var count : int = 3
var done = false

enum gamestate {START, BOBBER, FISHING, SCORE, LOSE}
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
				set_active(gamestate.SCORE)
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
				play_phrase(str(difficulty))
				vis = false
				set_active(gamestate.BOBBER)
			fishbox.counter.text = str(count)
		gamestate.SCORE:
			pass
		gamestate.LOSE:
			pass
	
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
		gamestate.SCORE:
			active_state = gamestate.SCORE
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			fishbox.visible = false
			bobber.visible = false
			intro.visible = false
			score_lab.visible = true
			score_num.visible = true
			timer_lab.visible = true
			timeout_lab.visible = true
		gamestate.LOSE:
			active_state = gamestate.LOSE
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
				print("start")
				set_active(gamestate.BOBBER)
				timer.start()
			gamestate.BOBBER:
				var check = bobber.check_target()
				if check:
					print("check: ", check)
					difficulty = check
					set_active(gamestate.FISHING)
					vis = false
			gamestate.FISHING:
				if fishbox.check_target():
					count -= 1
					fishbox.randomize_target()
				else:
					miss()
			gamestate.SCORE:
				pass
			gamestate.LOSE:
				pass
	
	elif event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()

func add_fish(size : float) -> void:
	fish += 1
	score += size
	score_num.text = str(score)
	spawner.spawn_size = size
	spawner.spawn_count = 1
	spawner.spawn_objects()
	spawner.global_position.y += (size * .25)

func miss() -> void:
	play_phrase("miss")
	set_active(gamestate.BOBBER)

func play_phrase(phrase : String) -> void:
	match phrase:
		"miss":
			phrases.text = "MISS!"
			phrases.visible = true
			await get_tree().create_timer(1.0).timeout
			phrases.visible = false
		"1.0":
			phrases.text = "OK"
			phrases.visible = true
			await get_tree().create_timer(1.0).timeout
			phrases.visible = false
		"2.0":
			phrases.text = "Nice!"
			phrases.visible = true
			await get_tree().create_timer(1.0).timeout
			phrases.visible = false
		"3.0":
			phrases.text = "YUGE!!"
			phrases.visible = true
			await get_tree().create_timer(1.0).timeout
			phrases.visible = false
		_:
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


func _on_level_time_timeout() -> void:
	done = true
