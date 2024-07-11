extends Node2D
## World script

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
