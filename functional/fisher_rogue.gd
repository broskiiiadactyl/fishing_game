extends Node3D

@onready var player := %AnimationPlayer

func _ready() -> void:
	player.play("Base/Hold")

func hold() -> void:
	player.play("Base/Hold")

func pull() -> void:
	player.play("Base/Pull")

func climb() -> void:
	player.play("Base/Climb")

func yay() -> void:
	player.play("Base/Yay")

func boo() -> void:
	player.play("Base/Boo")
