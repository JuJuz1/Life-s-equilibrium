extends Node2D
## Workplace mechanics

## When entering workplace
func _on_area_entered(area: Area2D) -> void:
	if area is Character:
		# Start timers and associated stuff
		area.energy -= 10
		print(area.energy)


## When leaving
func _on_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
	# Stop timers
