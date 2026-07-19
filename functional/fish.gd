extends Node3D

var size : float = 1.0
var counted : bool = false

func set_model(type : String) -> void:
	var fish : Node3D = self.get_node(str("%", type))
	
	fish.visible = true
	print("Fish: ", fish)
