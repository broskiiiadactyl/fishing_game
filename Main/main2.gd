extends Node3D

var vis := false
var score : int = 0
var fish : int = 0
var difficulty : float = 1.0
var direction : float = 1.0
var speed_mult : float = 0.05
var count : int = 3
var lives : int = 3

enum gamestate {START, BOBBER, FISHING, SCORE, LOSE}
var active_state = gamestate.START

@onready var fishbox := %Fishbox
@onready var bobber := %Bobber
@onready var spawner := %FishSpawner

@onready var intro : Label = %Intro
@onready var phrases : Label = %Phrases

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fishbox.visible = vis
	intro.visible = not vis

func _physics_process(_delta: float) -> void:
	match active_state:
		gamestate.START:
			intro.visible = true
		gamestate.BOBBER:
			if not vis:
				bobber.init_target()
				vis = true
		gamestate.FISHING:
			if not vis:
				fishbox.init_target(difficulty, difficulty/35)
				count = 3
				vis = true
			if count <= 0:
				vis = false
				set_active(gamestate.BOBBER)
			fishbox.counter.text = str(count)
		gamestate.SCORE:
			pass
		gamestate.LOSE:
			pass

func set_active(state) -> void:
	match state:
		gamestate.START:
			active_state = gamestate.START
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			fishbox.visible = false
			bobber.visible = false
			intro.visible = true
		gamestate.BOBBER:
			active_state = gamestate.BOBBER
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_ALWAYS
			fishbox.visible = false
			bobber.visible = true
			intro.visible = false
		gamestate.FISHING:
			active_state = gamestate.FISHING
			fishbox.process_mode = Node.PROCESS_MODE_ALWAYS
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			fishbox.visible = true
			bobber.visible = false
			intro.visible = false
		gamestate.SCORE:
			active_state = gamestate.SCORE
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			fishbox.visible = false
			bobber.visible = false
			intro.visible = false
		gamestate.LOSE:
			active_state = gamestate.LOSE
			fishbox.process_mode = Node.PROCESS_MODE_DISABLED
			bobber.process_mode = Node.PROCESS_MODE_DISABLED
			fishbox.visible = false
			bobber.visible = false
			intro.visible = false
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		match active_state:
			gamestate.START:
				print("start")
				set_active(gamestate.BOBBER)
			gamestate.BOBBER:
				var check = bobber.check_target()
				if check:
					print("check: ", check)
					difficulty = check
					bobber.stop()
					set_active(gamestate.FISHING)
					vis = false
			gamestate.FISHING:
				if fishbox.check_target():
					count -= 1
					add_fish()
					fishbox.randomize_target()
				else:
					miss()
			gamestate.SCORE:
				pass
			gamestate.LOSE:
				pass
	
	elif event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()

func add_fish() -> void:
	fish += 1
	spawner.spawn_count = 1
	spawner.spawn_objects()
	spawner.global_position.y += .25

func miss() -> void:
	if lives <= 0:
		set_active(gamestate.START)
		vis = false
	else:
		play_phrase("miss")
		set_active(gamestate.BOBBER)
		lives -= 1

func play_phrase(phrase : String) -> void:
	match phrase:
		"miss":
			phrases.text = "MISS!"
			phrases.visible = true
			await get_tree().create_timer(1.0).timeout
			phrases.visible = false
		"small":
			pass
		"med":
			pass
		"large":
			pass
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
