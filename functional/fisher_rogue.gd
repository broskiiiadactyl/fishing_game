extends Node3D

@onready var player := %AnimationPlayer
@onready var rod := %Rod

func _ready() -> void:
	player.play("Base/Hold")

func hold() -> void:
	rod.visible = true
	player.play("Base/Hold")

func pull() -> void:
	rod.visible = true
	player.play("Base/Pull")

func climb() -> void:
	rod.visible = false
	player.play("Base/Climb")

func yay() -> void:
	rod.visible = false
	player.play("Base/Yay")

func boo() -> void:
	rod.visible = false
	player.play("Base/Boo")
